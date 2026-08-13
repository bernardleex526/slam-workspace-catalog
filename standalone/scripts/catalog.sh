#!/usr/bin/env bash
# Shared catalog/manifest helpers for the SLAM workspace scripts.
# Sourced by fetch.sh / build.sh / lock.sh - defines functions only.
# shellcheck shell=bash

# validate_id <id> -> exit 0 iff the id is safe for path construction.
validate_id() {
  [[ "$1" =~ ^[a-z0-9_]+$ ]]
}

# canonical_within_root <path> -> exit 0 iff the canonicalized path stays
# inside the repository root (${ROOT} is defined by the calling script).
canonical_within_root() {
  local p canon
  p="$1"
  canon="${p}"
  if command -v realpath >/dev/null 2>&1; then
    canon="$(realpath -m "${p}")"
  fi
  [[ "${canon}" == "${ROOT}"/* ]]
}

# vcstool_available -> exit 0 iff 'vcs' is real vcstool ('vcs help' works).
# (On some systems /usr/bin/vcs is an unrelated "video contact sheet" tool.)
vcstool_available() {
  command -v vcs >/dev/null 2>&1 || return 1
  vcs help >/dev/null 2>&1
}

# catalog_column_index <file> <colname> -> 1-based index of the column if it
# appears exactly once in the header; prints nothing otherwise.
catalog_column_index() {
  local file="$1" col="$2"
  head -n1 "${file}" | tr -d '\r' | awk -F '\t' -v col="${col}" '
    { idx=0; n=0
      for (i=1; i<=NF; i++) { if ($i==col) { idx=i; n++ } }
      if (n==1) print idx }'
}

# catalog_validate_schema <file> -> exit 0 iff the catalog is strictly valid:
#   - header starts with 'id' and has unique 'build_mode' and 'manifest' columns
#   - every data row has exactly the header field count (NF)
#   - ids are [a-z0-9_]+, unique, and column 'id' is column 1
#   - build_mode in {generic,custom,heavy}
#   - manifest path is manifests/<id>.repos
catalog_validate_schema() {
  local file="$1" header nf id_col mode_col manifest_col bad
  [[ -f "${file}" && -s "${file}" ]] || { echo "catalog missing or empty: ${file}" >&2; return 1; }
  header="$(head -n1 "${file}" | tr -d '\r')"
  [[ "${header}" == id$'\t'* ]] || { echo "catalog header must start with 'id': ${file}" >&2; return 1; }
  nf="$(head -n1 "${file}" | tr -d '\r' | awk -F '\t' '{print NF}')"
  [[ "${nf}" -ge 3 ]] || { echo "catalog header has too few columns: ${file}" >&2; return 1; }
  id_col="$(catalog_column_index "${file}" id)"
  mode_col="$(catalog_column_index "${file}" build_mode)"
  manifest_col="$(catalog_column_index "${file}" manifest)"
  [[ "${id_col}" == "1" ]] || { echo "catalog column 'id' must be column 1: ${file}" >&2; return 1; }
  [[ -n "${mode_col}" ]] || { echo "catalog must have a unique 'build_mode' column: ${file}" >&2; return 1; }
  [[ -n "${manifest_col}" ]] || { echo "catalog must have a unique 'manifest' column: ${file}" >&2; return 1; }
  bad="$(tr -d '\r' < "${file}" | awk -F '\t' -v nf="${nf}" -v mc="${mode_col}" -v xc="${manifest_col}" '
    NR==1 { next }
    NF != nf { print "row " NR ": field count " NF " != header " nf; bad=1; next }
    $1 !~ /^[a-z0-9_]+$/ { print "row " NR ": bad id \"" $1 "\""; bad=1 }
    $mc !~ /^(generic|custom|heavy)$/ { print "row " NR ": bad build_mode \"" $mc "\""; bad=1 }
    $xc !~ /^manifests\/[a-z0-9_]+\.repos$/ { print "row " NR ": bad manifest path \"" $xc "\""; bad=1 }')"
  if [[ -n "${bad}" ]]; then
    echo "catalog schema invalid: ${file}" >&2
    echo "${bad}" >&2
    return 1
  fi
  bad="$(awk -F '\t' 'NR>1 {print $1}' "${file}" | sort | uniq -d)"
  if [[ -n "${bad}" ]]; then
    echo "catalog ids not unique: ${file}" >&2
    return 1
  fi
  return 0
}

# catalog_has_id <file> <id> -> exit 0 iff the id exactly matches column 1.
catalog_has_id() {
  local file="$1" id="$2"
  awk -F '\t' -v id="${id}" '$1==id {found=1; exit} END {exit !found}' "${file}"
}

# catalog_get_field <file> <id> <colname> -> field value for the id (exact
# match, dynamic column index); empty if the id or column is unknown.
catalog_get_field() {
  local file="$1" id="$2" colname="$3" col
  col="$(catalog_column_index "${file}" "${colname}")"
  [[ -n "${col}" ]] || return 1
  tr -d '\r' < "${file}" | awk -F '\t' -v id="${id}" -v col="${col}" '$1==id {print $col; exit}'
}

# manifest_repos <file> -> one "name<TAB>url<TAB>version" line per repository
# entry of a vcstool .repos manifest.
manifest_repos() {
  local file="$1"
  awk '
    function flush() {
      if (name != "") { print name "\t" url "\t" ver; name=""; url=""; ver="" }
    }
    /^[[:space:]][[:space:]][^[:space:]#].*:$/ {
      flush()
      name=$0; sub(/^[[:space:]]+/, "", name); sub(/:$/, "", name)
      next
    }
    /^[[:space:]][[:space:]][[:space:]][[:space:]]url:[[:space:]]/ {
      url=$0; sub(/^[[:space:]]*url:[[:space:]]*/, "", url); next
    }
    /^[[:space:]][[:space:]][[:space:]][[:space:]]version:[[:space:]]/ {
      ver=$0; sub(/^[[:space:]]*version:[[:space:]]*/, "", ver); next
    }
    END { flush() }
  ' "${file}"
}

# manifest_entry_attrs <file> <name> -> prints the indented attribute lines
# (type/url/version) of the named repository entry.
manifest_entry_attrs() {
  local file="$1" want="$2" cur=0 line n
  while IFS= read -r line; do
    if [[ "${line}" =~ ^[[:space:]][[:space:]][^[:space:]#].*:$ ]]; then
      n="${line}"
      n="${n#"${n%%[![:space:]]*}"}"
      n="${n%:}"
      [[ "${n}" == "${want}" ]] && cur=1 || cur=0
    elif [[ ${cur} -eq 1 ]] && [[ "${line}" =~ ^[[:space:]]{4}(type|url|version):[[:space:]] ]]; then
      printf '%s\n' "${line}"
    fi
  done < "${file}"
}

# repo_complete <ws-src> <name> -> exit 0 iff the checkout is complete: a
# non-empty directory that is a git working tree.
repo_complete() {
  local src="$1" name="$2" d="${src}/${name}"
  [[ -d "${d}" ]] || return 1
  [[ -n "$(find "${d}" -mindepth 1 -print -quit)" ]] || return 1
  # Must be its OWN checkout: 'git -C' alone would resolve the enclosing
  # repository (this catalog repo itself), making any plain directory look
  # complete. Require a .git entry plus --show-toplevel == the directory.
  [[ -e "${d}/.git" ]] || return 1
  [[ "$(git -C "${d}" rev-parse --show-toplevel 2>/dev/null)" == "${d}" ]]
}

# missing_repos <manifest> <ws-src> -> prints names of manifest repos whose
# checkout is missing or incomplete; nothing if all are complete. Always
# exits 0.
missing_repos() {
  local manifest="$1" src="$2" name
  while IFS=$'\t' read -r name _ _; do
    [[ -n "${name}" ]] || continue
    repo_complete "${src}" "${name}" || echo "${name}"
  done < <(manifest_repos "${manifest}")
  return 0
}

# manifest_has_repo <file> <name> -> exit 0 iff the manifest declares <name>.
manifest_has_repo() {
  local file="$1" want="$2" name
  while IFS=$'\t' read -r name _ _; do
    [[ "${name}" == "${want}" ]] && return 0
  done < <(manifest_repos "${file}")
  return 1
}

# extra_repos <manifest> <src-dir> -> prints names of top-level entries in
# <src-dir> that are independent git checkouts but are NOT declared in the
# manifest (dot-entries are ignored). Always exits 0.
extra_repos() {
  local manifest="$1" src="$2" entry name
  while IFS= read -r entry; do
    name="$(basename "${entry}")"
    [[ "${name}" == .* ]] && continue
    repo_complete "${src}" "${name}" || continue
    manifest_has_repo "${manifest}" "${name}" || echo "${name}"
  done < <(find "${src}" -mindepth 1 -maxdepth 1 2>/dev/null | sort)
  return 0
}

# validate_repos_file <file> -> exit 0 iff the file is a well-formed vcstool
# .repos: a top-level 'repositories:' map with at least one repository node,
# and every node carries indented type/url (and version) attributes. Empty or
# pseudo .repos files (e.g. just 'repositories:') are rejected.
validate_repos_file() {
  local file="$1" first bad
  [[ -s "${file}" ]] || { echo "empty .repos file" >&2; return 1; }
  first="$(awk 'NF {print; exit}' "${file}")"
  [[ "${first}" == "repositories:" ]] || {
    echo "missing top-level 'repositories:' key" >&2
    return 1
  }
  bad="$(awk '
    function flush() {
      if (name != "") {
        if (type == "" || url == "") {
          print "repository \"" name "\" lacks type/url attributes"; bad=1
        }
        name=""; type=""; url=""
      }
    }
    /^repositories:[[:space:]]*$/ { next }
    /^[[:space:]][[:space:]][^[:space:]#].*:$/ {
      flush()
      n++
      name=$0; sub(/^[[:space:]]+/, "", name); sub(/:$/, "", name)
      next
    }
    /^[[:space:]][[:space:]][[:space:]][[:space:]]type:[[:space:]]/ { type=1; next }
    /^[[:space:]][[:space:]][[:space:]][[:space:]]url:[[:space:]]/ { url=1; next }
    /^[[:space:]][[:space:]][[:space:]][[:space:]]version:[[:space:]]/ { ver=1; next }
    NF && $0 !~ /^[[:space:]]/ && $0 !~ /^[[:space:]]*#/ {
      print "unexpected top-level content: " $0; bad=1
    }
    END {
      flush()
      if (n == 0) { print "no repository entries"; bad=1 }
    }' "${file}")"
  if [[ -n "${bad}" ]]; then
    echo "invalid .repos file:" >&2
    echo "${bad}" >&2
    return 1
  fi
  return 0
}
