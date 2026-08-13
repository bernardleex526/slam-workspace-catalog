#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./catalog.sh
source "${ROOT}/scripts/catalog.sh"

CATALOG="${ROOT}/catalog.tsv"

usage() {
  echo "Usage: $0 [--local] <algorithm-id>" >&2
  echo "  default : write locks/<id>-exact.repos (committed reproducibility baseline)" >&2
  echo "  --local : write locks/<id>-local.repos (personal snapshot, git-ignored)" >&2
  echo "  <algorithm-id> must match a catalog id: [a-z0-9_]+." >&2
  exit 2
}

MODE="exact"
ALGORITHM=""

# Strict option parsing: only --local (plus -h/--help) is accepted. Unknown
# options, option-looking ids, and extra positional arguments are rejected.
# "--" ends option parsing.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) MODE="local"; shift ;;
    -h|--help) usage ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage ;;
    *) ALGORITHM="$1"; shift; break ;;
  esac
done
while [[ $# -gt 0 ]]; do
  if [[ -n "${ALGORITHM}" ]]; then
    echo "Unexpected extra argument: $1" >&2
    usage
  fi
  ALGORITHM="$1"
  shift
done
[[ -n "${ALGORITHM}" ]] || usage

# The id is used to build filesystem paths: only catalog-style identifiers.
validate_id "${ALGORITHM}" || {
  echo "Invalid algorithm id: '${ALGORITHM}' (must match [a-z0-9_]+)" >&2
  exit 2
}

# The catalog schema must be valid and the id must be an exact hit.
catalog_validate_schema "${CATALOG}" || {
  echo "Refusing to lock against an invalid catalog schema." >&2
  exit 1
}
catalog_has_id "${CATALOG}" "${ALGORITHM}" || {
  echo "Unknown algorithm id: ${ALGORITHM} (not in catalog)" >&2
  bash "${ROOT}/scripts/list.sh"
  exit 2
}

SRC="${ROOT}/workspaces/${ALGORITHM}_ws/src"
OUT="${ROOT}/locks/${ALGORITHM}-${MODE}.repos"

# Defense in depth: canonical paths must stay inside the repository root.
canonical_within_root "${SRC}" || {
  echo "Refusing path outside repository root: ${SRC}" >&2
  exit 2
}
canonical_within_root "${OUT}" || {
  echo "Refusing path outside repository root: ${OUT}" >&2
  exit 2
}

if [[ ! -d "${SRC}" ]]; then
  echo "No workspace found: ${SRC}" >&2
  echo "Run scripts/fetch.sh ${ALGORITHM} first." >&2
  exit 2
fi

# Locking an empty workspace would record nothing: refuse.
if [[ -z "$(find "${SRC}" -mindepth 1 -print -quit)" ]]; then
  echo "Workspace is empty: ${SRC} (nothing to lock)" >&2
  exit 1
fi

# Derive the manifest from the catalog (same source of truth as fetch.sh).
MANIFEST_REL="$(catalog_get_field "${CATALOG}" "${ALGORITHM}" manifest)"
[[ -n "${MANIFEST_REL}" ]] || {
  echo "Catalog entry has no manifest for ${ALGORITHM}" >&2
  exit 1
}
MANIFEST="${ROOT}/${MANIFEST_REL}"
canonical_within_root "${MANIFEST}" || {
  echo "Refusing manifest path outside repository root: ${MANIFEST}" >&2
  exit 2
}
[[ -f "${MANIFEST}" ]] || {
  echo "Manifest missing: ${MANIFEST}" >&2
  exit 1
}

# Only lock workspaces whose manifest is FULLY checked out. A partial
# workspace must never overwrite an existing lock.
missing="$(missing_repos "${MANIFEST}" "${SRC}")"
if [[ -n "${missing}" ]]; then
  echo "Workspace is incomplete (missing/incomplete manifest repos):" >&2
  echo "${missing}" | sed 's/^/  /' >&2
  echo "Refusing to overwrite ${OUT}; run scripts/fetch.sh ${ALGORITHM} to repair the workspace." >&2
  exit 1
fi

vcstool_available || {
  echo "vcstool not found (or not the real vcstool). Install: sudo apt install python3-vcstool" >&2
  exit 1
}

mkdir -p "${ROOT}/locks"
# Export into a temp file in the SAME directory as the final lock so the
# later mv is atomic. On any failure (or empty/invalid output) an existing
# lock file is left untouched and the temp file is removed via the trap.
TMP="$(mktemp "${ROOT}/locks/.${ALGORITHM}-${MODE}.repos.XXXXXX")"
cleanup_tmp() { rm -f "${TMP}"; }
trap cleanup_tmp EXIT

if ! vcs export --exact "${SRC}" > "${TMP}"; then
  echo "vcs export failed for ${SRC}; keeping existing lock ${OUT} untouched." >&2
  exit 1
fi

if [[ ! -s "${TMP}" ]]; then
  echo "vcs export produced empty output; keeping existing lock ${OUT} untouched." >&2
  exit 1
fi

# The exported .repos must contain REAL repository entries (nodes with
# indented type/url/version attributes); empty or pseudo .repos are rejected.
if ! validate_repos_file "${TMP}"; then
  echo "vcs export output is not a valid .repos file; keeping existing lock ${OUT} untouched." >&2
  exit 1
fi

mv -f "${TMP}" "${OUT}"
trap - EXIT
echo "Wrote ${OUT}"
