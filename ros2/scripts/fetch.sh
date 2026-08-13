#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./catalog.sh
source "${ROOT}/scripts/catalog.sh"

CATALOG="${ROOT}/catalog.tsv"

usage() {
  echo "Usage: $0 [--update] <project-id>" >&2
  echo "  default  : import the manifest into workspaces/<id>_ws/src. An existing" >&2
  echo "             src/ is only treated as fetched when EVERY manifest repo is" >&2
  echo "             checked out; missing repos are re-imported (with retries)." >&2
  echo "  --update : vcs pull the repos currently checked out. It does NOT align" >&2
  echo "             the repo set or revisions with the manifest; if the repo set" >&2
  echo "             differs from the manifest it refuses (re-import instead)." >&2
  echo "  <project-id> must match a catalog id: [a-z0-9_]+." >&2
  exit 2
}

# repair_missing <src-dir>: imports the manifest repos that are missing or
# incomplete in <src-dir>, with bounded retries. Exits 0 when the manifest is
# fully checked out, 1 with an actionable message otherwise.
repair_missing() {
  local target="$1" missing attempt name TMP_REPOS
  missing="$(missing_repos "${MANIFEST}" "${target}")"
  attempt=0
  while [[ -n "${missing}" && ${attempt} -lt 3 ]]; do
    attempt=$((attempt + 1))
    echo "Repair attempt ${attempt} of 3: importing missing repos" >&2
    TMP_REPOS="$(mktemp "${WS}/.missing-repos.XXXXXX")"
    trap 'rm -f "${TMP_REPOS:-}"' EXIT
    {
      echo "repositories:"
      while IFS= read -r name; do
        [[ -n "${name}" ]] || continue
        printf '  %s:\n' "${name}"
        manifest_entry_attrs "${MANIFEST}" "${name}"
      done <<< "${missing}"
    } > "${TMP_REPOS}"
    if ! vcs import "${target}" < "${TMP_REPOS}"; then
      echo "WARNING: vcs import reported errors on attempt ${attempt}" >&2
    fi
    rm -f "${TMP_REPOS}"
    missing="$(missing_repos "${MANIFEST}" "${target}")"
  done
  trap - EXIT
  if [[ -n "${missing}" ]]; then
    echo "ERROR: ${PROJECT} workspace is still incomplete after ${attempt} attempt(s)." >&2
    echo "Missing/incomplete checkouts:" >&2
    while IFS= read -r name; do
      [[ -n "${name}" ]] || continue
      if [[ -e "${target}/${name}" ]]; then
        echo "  ${name}: directory exists but is not a complete checkout." >&2
        echo "    Remove it and re-run: rm -rf '${target}/${name}' && $0 ${PROJECT}" >&2
      else
        echo "  ${name}: not checked out." >&2
      fi
    done <<< "${missing}"
    echo "Or remove the whole workspace for a fresh exact import:" >&2
    echo "  rm -rf ${WS}/src && $0 ${PROJECT}" >&2
    return 1
  fi
  return 0
}

UPDATE=0
PROJECT=""

# Strict option parsing: only --update (plus -h/--help) is accepted. Unknown
# options, option-looking ids, and extra positional arguments are rejected.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --update) UPDATE=1; shift ;;
    -h|--help) usage ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage ;;
    *) PROJECT="$1"; shift; break ;;
  esac
done
while [[ $# -gt 0 ]]; do
  if [[ -n "${PROJECT}" ]]; then
    echo "Unexpected extra argument: $1" >&2
    usage
  fi
  PROJECT="$1"
  shift
done
[[ -n "${PROJECT}" ]] || usage

# The id is used to build filesystem paths: only catalog-style identifiers.
validate_id "${PROJECT}" || {
  echo "Invalid project id: '${PROJECT}' (must match [a-z0-9_]+)" >&2
  exit 2
}

# Catalog schema must be valid and the id must be an exact hit; the manifest
# path comes from the catalog, never from user input.
catalog_validate_schema "${CATALOG}" || {
  echo "Refusing to fetch against an invalid catalog schema." >&2
  exit 1
}
catalog_has_id "${CATALOG}" "${PROJECT}" || {
  echo "Unknown project id: ${PROJECT} (not in catalog)" >&2
  bash "${ROOT}/scripts/list.sh"
  exit 2
}

MANIFEST_REL="$(catalog_get_field "${CATALOG}" "${PROJECT}" manifest)"
[[ -n "${MANIFEST_REL}" ]] || {
  echo "Catalog entry has no manifest for ${PROJECT}" >&2
  exit 1
}
MANIFEST="${ROOT}/${MANIFEST_REL}"
WS="${ROOT}/workspaces/${PROJECT}_ws"

canonical_within_root "${MANIFEST}" || {
  echo "Refusing manifest path outside repository root: ${MANIFEST}" >&2
  exit 2
}
canonical_within_root "${WS}" || {
  echo "Refusing workspace path outside repository root: ${WS}" >&2
  exit 2
}
[[ -f "${MANIFEST}" ]] || {
  echo "Manifest missing: ${MANIFEST}" >&2
  exit 1
}

if [[ "${UPDATE}" -eq 1 ]]; then
  # --update is a vcs pull of the CURRENT checkouts only. It does not align
  # the repo set or revisions with the manifest and must not pretend to.
  if [[ ! -d "${WS}/src" ]] || [[ -z "$(find "${WS}/src" -mindepth 1 -print -quit)" ]]; then
    echo "No existing workspace to update: ${WS}/src" >&2
    echo "Import from scratch instead: $0 ${PROJECT}" >&2
    exit 1
  fi
  mismatch="$(missing_repos "${MANIFEST}" "${WS}/src")"
  extras="$(extra_repos "${MANIFEST}" "${WS}/src")"
  if [[ -n "${mismatch}" || -n "${extras}" ]]; then
    echo "Workspace repo set does not match the manifest: ${WS}/src" >&2
    if [[ -n "${mismatch}" ]]; then
      echo "Missing/incomplete checkouts:" >&2
      echo "${mismatch}" | sed 's/^/  /' >&2
    fi
    if [[ -n "${extras}" ]]; then
      echo "Extra checkouts not in the manifest:" >&2
      echo "${extras}" | sed 's/^/  /' >&2
    fi
    echo "--update only pulls repos that are already checked out; it will NOT" >&2
    echo "add or remove repos. Remove the workspace and re-import exactly:" >&2
    echo "  rm -rf ${WS}/src && $0 ${PROJECT}" >&2
    exit 1
  fi
  vcstool_available || {
    echo "vcstool not found (or not the real vcstool). Install: sudo apt install python3-vcstool" >&2
    exit 1
  }
  echo "Pulling current checkouts in ${WS}/src (vcs pull)."
  echo "NOTE: this does NOT guarantee the revisions recorded in the manifest."
  vcs pull "${WS}/src"
  echo "Updated ${PROJECT} checkouts (current HEADs)."
  exit 0
fi

# Normal import path. A src/ that merely contains files is NOT "fetched":
# every manifest repo must be a complete checkout.
mkdir -p "${WS}"
missing="$(missing_repos "${MANIFEST}" "${WS}/src")"
if [[ -z "${missing}" ]]; then
  echo "Workspace already fetched and complete: ${WS}/src"
  echo "Nothing to do. Use --update to vcs pull the current checkouts."
  exit 0
fi

vcstool_available || {
  echo "vcstool not found (or not the real vcstool). Install: sudo apt install python3-vcstool" >&2
  exit 1
}

if [[ ! -d "${WS}/src" ]] || [[ -z "$(find "${WS}/src" -mindepth 1 -print -quit)" ]]; then
  # First fetch: import into a staging directory, verify completeness, then
  # atomically move it into place so a half-finished import is never visible.
  STAGING="$(mktemp -d "${WS}/.src-staging.XXXXXX")"
  trap 'rm -rf "${STAGING}"' EXIT
  echo "Fetching ${PROJECT} into ${WS}/src (staging, atomic)"
  if ! vcs import "${STAGING}" < "${MANIFEST}"; then
    echo "WARNING: initial import incomplete; repairing missing repos." >&2
  fi
  if ! repair_missing "${STAGING}"; then
    rm -rf "${STAGING}"
    exit 1
  fi
  while IFS= read -r -d '' gitdir; do
    repo_dir="$(dirname "${gitdir}")"
    git -C "${repo_dir}" submodule update --init --recursive
  done < <(find "${STAGING}" -type d -name .git -print0)
  if [[ -d "${WS}/src" ]]; then
    rmdir "${WS}/src"
  fi
  mv "${STAGING}" "${WS}/src"
  trap - EXIT
else
  # Existing partial workspace: repair in place with a manifest-driven diff
  # (only missing repos are imported, so vcs never hits existing directories).
  echo "Existing workspace found: ${WS}/src; verifying manifest repos"
  if ! repair_missing "${WS}/src"; then
    exit 1
  fi
  while IFS= read -r -d '' gitdir; do
    repo_dir="$(dirname "${gitdir}")"
    git -C "${repo_dir}" submodule update --init --recursive
  done < <(find "${WS}/src" -type d -name .git -print0)
fi

echo "Fetched ${PROJECT} into ${WS}/src"
