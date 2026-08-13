#!/usr/bin/env bash
# Lightweight smoke tests for the SLAM workspace catalog.
# No network, no build, no source downloads, no external dependencies.
# Usage: bash tests/smoke.sh
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

TREES=(ros1 ros2 standalone)
PASSED=0
FAILED=0

ok()   { PASSED=$((PASSED + 1)); echo "PASS: $1"; }
fail() { FAILED=$((FAILED + 1)); echo "FAIL: $1"; }

# Interpreter for syntax checks and for running the scripts under test.
BASH_CMD="bash"
command -v bash >/dev/null 2>&1 || BASH_CMD="sh"

echo "== 1. bash syntax check (${BASH_CMD} -n) =="
for t in "${TREES[@]}"; do
  while IFS= read -r s; do
    if "${BASH_CMD}" -n "${s}"; then
      ok "syntax: ${s}"
    else
      fail "syntax: ${s}"
    fi
  done < <(find "${t}/scripts" -maxdepth 1 -name '*.sh' | sort)
done

echo "== 2. catalog-manifest consistency =="
for t in "${TREES[@]}"; do
  header="$(head -n1 "${t}/catalog.tsv")"
  if [[ "${header}" == id* ]]; then
    ok "${t}: catalog starts with 'id' header"
  else
    fail "${t}: catalog header is '${header}'"
  fi
  if [[ "${header}" == *"build_mode"* ]]; then
    ok "${t}: catalog has build_mode column"
  else
    fail "${t}: catalog missing build_mode column"
  fi

  bad_ids="$(awk -F '\t' 'NR>1 && $1 !~ /^[a-z0-9_]+$/ {print NR ":" $1}' "${t}/catalog.tsv")"
  if [[ -z "${bad_ids}" ]]; then
    ok "${t}: catalog ids well-formed ([a-z0-9_]+)"
  else
    fail "${t}: bad catalog ids -> ${bad_ids}"
  fi

  bad_modes="$(awk -F '\t' 'NR>1 && $5 !~ /^(generic|custom|heavy)$/ {print NR ":" $5}' "${t}/catalog.tsv")"
  if [[ -z "${bad_modes}" ]]; then
    ok "${t}: build_mode values in {generic,custom,heavy}"
  else
    fail "${t}: bad build_mode values -> ${bad_modes}"
  fi

  dupes="$(awk -F '\t' 'NR>1 {print $1}' "${t}/catalog.tsv" | sort | uniq -d)"
  if [[ -z "${dupes}" ]]; then
    ok "${t}: catalog ids unique"
  else
    fail "${t}: duplicate catalog ids -> ${dupes}"
  fi

  missing=""
  while IFS= read -r m; do
    [[ -f "${t}/${m}" ]] || missing="${missing} ${m}"
  done < <(awk -F '\t' 'NR>1 && $6 ~ /^manifests\// {print $6}' "${t}/catalog.tsv")
  if [[ -z "${missing}" ]]; then
    ok "${t}: every catalog manifest file exists"
  else
    fail "${t}: missing manifest files ->${missing}"
  fi

  unreferenced=""
  while IFS= read -r m; do
    grep -Fq "${m}" "${t}/catalog.tsv" || unreferenced="${unreferenced} ${m}"
  done < <(find "${t}/manifests" -maxdepth 1 -name '*.repos' -printf '%f\n' | sort)
  if [[ -z "${unreferenced}" ]]; then
    ok "${t}: every manifests/*.repos is referenced in catalog"
  else
    fail "${t}: unreferenced manifests ->${unreferenced}"
  fi
done

echo "== 3. invalid id behavior (expect exit 2, no network) =="
for t in "${TREES[@]}"; do
  for s in fetch build lock; do
    "${BASH_CMD}" "${t}/scripts/${s}.sh" __definitely_invalid__ >/dev/null 2>&1
    rc=$?
    if [[ ${rc} -eq 2 ]]; then
      ok "${t}/scripts/${s}.sh: invalid id exits 2"
    else
      fail "${t}/scripts/${s}.sh: invalid id exit ${rc}, want 2"
    fi
  done
  "${BASH_CMD}" "${t}/scripts/fetch.sh" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -eq 2 ]]; then
    ok "${t}/fetch.sh: no-arg exits 2"
  else
    fail "${t}/fetch.sh: no-arg exit ${rc}, want 2"
  fi
  "${BASH_CMD}" "${t}/scripts/list.sh" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -eq 0 ]]; then
    ok "${t}/list.sh: exits 0"
  else
    fail "${t}/list.sh: exit ${rc}, want 0"
  fi
done

echo "== 3b. fetch.sh completeness: fully checked-out workspace is a no-op =="
for t in "${TREES[@]}"; do
  id="$(awk -F '\t' 'NR==2 {print $1}' "${t}/catalog.tsv")"
  ws="${t}/workspaces/${id}_ws"
  if [[ -e "${ws}" ]]; then
    echo "SKIP: ${t}/fetch.sh completeness (${ws} already exists, leaving it untouched)"
    continue
  fi
  # A merely non-empty src/ must NOT be treated as fetched: build a workspace
  # with a git checkout for EVERY manifest repository.
  (
    source "${t}/scripts/catalog.sh"
    manifest="$(catalog_get_field "${t}/catalog.tsv" "${id}" manifest)"
    mkdir -p "${ws}/src"
    while IFS=$'\t' read -r name _ _; do
      [[ -n "${name}" ]] || continue
      mkdir -p "${ws}/src/${name}"
      : > "${ws}/src/${name}/README"
      git -C "${ws}/src/${name}" init -q . 2>/dev/null || true
    done < <(manifest_repos "${t}/${manifest}")
  )
  if "${BASH_CMD}" "${t}/scripts/fetch.sh" "${id}" >/dev/null 2>&1; then
    ok "${t}/fetch.sh: complete workspace no-op exits 0 (no vcs required)"
  else
    fail "${t}/fetch.sh: complete workspace no-op exited non-zero"
  fi
  rm -rf "${ws}"
done

echo "== 4. lock naming and ignore policy =="
for t in "${TREES[@]}"; do
  if grep -q -- '-exact\.repos' "${t}/scripts/lock.sh"; then
    ok "${t}/lock.sh: produces -exact.repos"
  else
    fail "${t}/lock.sh: does not produce -exact.repos"
  fi
  if grep -q -- '-local\.repos' "${t}/scripts/lock.sh"; then
    ok "${t}/lock.sh: has --local mode"
  else
    fail "${t}/lock.sh: no --local mode"
  fi
  if grep -q 'locks/\*-exact\.repos' "${t}/.gitignore"; then
    fail "${t}/.gitignore: ignores exact locks (must be committed for reproducibility)"
  else
    ok "${t}/.gitignore: exact locks NOT ignored (committed)"
  fi
  if grep -q 'locks/\*-local\.repos' "${t}/.gitignore"; then
    ok "${t}/.gitignore: local locks ignored"
  else
    fail "${t}/.gitignore: local locks not ignored"
  fi
  if grep -q -- '-exact\.repos' "${t}/README.md"; then
    ok "${t}/README.md: documents exact lock policy"
  else
    fail "${t}/README.md: does not document exact lock policy"
  fi
done

echo "== 5. unified .gitignore across trees =="
for t in ros2 standalone; do
  if cmp -s ros1/.gitignore "${t}/.gitignore"; then
    ok "${t}/.gitignore identical to ros1/.gitignore"
  else
    fail "${t}/.gitignore differs from ros1/.gitignore"
  fi
done

echo "== 6. lock.sh strict argument validation (traversal / extra args) =="
for t in "${TREES[@]}"; do
  first_id="$(awk -F '\t' 'NR==2 {print $1}' "${t}/catalog.tsv")"
  before="$(find "${t}/locks" -mindepth 1 | sort)"

  for bad in "../${first_id}" "${first_id}/../x" "Bad-ID" "with-dash" "" "--bogus" "-x"; do
    "${BASH_CMD}" "${t}/scripts/lock.sh" "${bad}" >/dev/null 2>&1
    rc=$?
    if [[ ${rc} -eq 2 ]]; then
      ok "${t}/lock.sh: arg '${bad}' exits 2"
    else
      fail "${t}/lock.sh: arg '${bad}' exit ${rc}, want 2"
    fi
  done

  "${BASH_CMD}" "${t}/scripts/lock.sh" "${first_id}" extra >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/lock.sh: extra positional arg exits 2" \
                    || fail "${t}/lock.sh: extra positional arg exit ${rc}, want 2"

  "${BASH_CMD}" "${t}/scripts/lock.sh" --local "${first_id}" extra >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/lock.sh: --local + extra arg exits 2" \
                    || fail "${t}/lock.sh: --local + extra arg exit ${rc}, want 2"

  "${BASH_CMD}" "${t}/scripts/lock.sh" "${first_id}" --local >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/lock.sh: option after positional exits 2" \
                    || fail "${t}/lock.sh: option after positional exit ${rc}, want 2"

  "${BASH_CMD}" "${t}/scripts/lock.sh" --local >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/lock.sh: --local without id exits 2" \
                    || fail "${t}/lock.sh: --local without id exit ${rc}, want 2"

  "${BASH_CMD}" "${t}/scripts/lock.sh" no_such_entry_zz >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/lock.sh: unknown catalog id exits 2" \
                    || fail "${t}/lock.sh: unknown catalog id exit ${rc}, want 2"

  after="$(find "${t}/locks" -mindepth 1 | sort)"
  if [[ "${before}" == "${after}" ]]; then
    ok "${t}/lock.sh: rejected args created no lock files"
  else
    fail "${t}/lock.sh: rejected args created files -> ${after}"
  fi
done

echo "== 7. lock.sh atomic write: existing lock preserved on failure =="
SMOKE_TMP="$(mktemp -d)"
SMOKE_CLEAN=()
cleanup_smoke() {
  rm -rf "${SMOKE_TMP}"
  if [[ ${#SMOKE_CLEAN[@]} -gt 0 ]]; then
    rm -rf -- "${SMOKE_CLEAN[@]}" 2>/dev/null || true
  fi
}
trap cleanup_smoke EXIT

cat > "${SMOKE_TMP}/vcs" <<'EOF'
#!/usr/bin/env bash
# Offline stub for vcstool (help/import/export). Never touches the network.
[[ "${1:-}" == "help" ]] && exit 0
cmd="${1:-}"
if [[ "${cmd}" == "export" ]]; then
  case "${VCS_STUB_MODE:-fail}" in
    ok)      cat "${VCS_STUB_OUTPUT}" ;;
    empty)   : ;;
    invalid) printf 'not: [valid yaml\n' ;;
    hollow)  printf 'repositories:\n' ;;
    bare)    printf 'repositories:\n  fake_repo:\n' ;;
    *)       echo "stub vcs: simulated export failure" >&2; exit 1 ;;
  esac
  exit 0
fi
if [[ "${cmd}" == "import" ]]; then
  # parse repository names from the .repos read on stdin
  names="$(awk '/^[[:space:]][[:space:]][^[:space:]#].*:$/ { n=$0; sub(/^[[:space:]]+/, "", n); sub(/:$/, "", n); print n }')"
  case "${VCS_STUB_MODE:-ok}" in
    never)
      # always drop the last repository -> imports can never complete
      names="$(printf '%s\n' "${names}" | sed '$d')" ;;
    dropone)
      # drop the last repository on the FIRST invocation only
      if [[ ! -f "${VCS_STUB_STATE:?dropone requires VCS_STUB_STATE}" ]]; then
        : > "${VCS_STUB_STATE}"
        names="$(printf '%s\n' "${names}" | sed '$d')"
      fi ;;
    fail)
      echo "stub vcs: simulated import failure" >&2; exit 1 ;;
  esac
  for n in ${names}; do
    mkdir -p "${2}/${n}"
    : > "${2}/${n}/README"
    git -C "${2}/${n}" init -q . 2>/dev/null || true
  done
  exit 0
fi
echo "stub vcs: unsupported command ${cmd}" >&2
exit 1
EOF
chmod +x "${SMOKE_TMP}/vcs"
mkdir -p "${SMOKE_TMP}/nobins"

cat > "${SMOKE_TMP}/nobins/vcs" <<'EOF'
#!/usr/bin/env bash
# A non-vcstool binary (e.g. /usr/bin/vcs "video contact sheet") that is
# found by 'command -v vcs' but is not functional vcstool.
echo "bogus vcs: not vcstool" >&2
exit 1
EOF
chmod +x "${SMOKE_TMP}/nobins/vcs"

cat > "${SMOKE_TMP}/valid.repos" <<'EOF'
repositories:
  fake_repo:
    type: git
    url: file:///nonexistent/fake_repo.git
    version: 0123456789abcdef0123456789abcdef01234567
EOF

for t in "${TREES[@]}"; do
  id="$(awk -F '\t' 'NR==2 {print $1}' "${t}/catalog.tsv")"
  ws="${ROOT}/${t}/workspaces/${id}_ws"
  exact="${ROOT}/${t}/locks/${id}-exact.repos"
  local_lk="${ROOT}/${t}/locks/${id}-local.repos"

  if [[ -e "${exact}" || -e "${local_lk}" ]]; then
    echo "SKIP ${t}: lock files already exist (${exact} / ${local_lk}); leaving untouched"
    continue
  fi

  # The completeness gate (P1) requires EVERY manifest repo to be a git
  # checkout before an export may overwrite a lock: build a complete fixture.
  (
    source "${t}/scripts/catalog.sh"
    manifest="$(catalog_get_field "${t}/catalog.tsv" "${id}" manifest)"
    mkdir -p "${ws}/src"
    while IFS=$'\t' read -r name _ _; do
      [[ -n "${name}" ]] || continue
      mkdir -p "${ws}/src/${name}"
      : > "${ws}/src/${name}/README"
      git -C "${ws}/src/${name}" init -q . 2>/dev/null || true
    done < <(manifest_repos "${t}/${manifest}")
  )
  SMOKE_CLEAN+=("${ws}")

  printf 'OLD-EXACT-SENTINEL\n' > "${exact}"
  printf 'OLD-LOCAL-SENTINEL\n' > "${local_lk}"
  SMOKE_CLEAN+=("${exact}" "${local_lk}")

  # vcs missing from PATH (only a non-vcstool binary present) -> fail,
  # old exact lock preserved (deterministic regardless of system PATH)
  PATH="${SMOKE_TMP}/nobins:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -ne 0 ]] && [[ "$(cat "${exact}")" == "OLD-EXACT-SENTINEL" ]]; then
    ok "${t}/lock.sh: vcs missing -> fails and keeps old exact lock"
  else
    fail "${t}/lock.sh: vcs missing rc=${rc}, lock='$(cat "${exact}" 2>/dev/null)'"
  fi

  # vcs present but fails / empty / invalid / pseudo-.repos output ->
  # old exact lock preserved
  for mode in fail empty invalid hollow bare; do
    VCS_STUB_MODE="${mode}" PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" "${id}" >/dev/null 2>&1
    rc=$?
    if [[ ${rc} -ne 0 ]] && [[ "$(cat "${exact}")" == "OLD-EXACT-SENTINEL" ]]; then
      ok "${t}/lock.sh: vcs mode '${mode}' -> old exact lock preserved"
    else
      fail "${t}/lock.sh: vcs mode '${mode}' rc=${rc}, lock='$(cat "${exact}" 2>/dev/null)'"
    fi
  done

  # same guarantee for the --local lock
  VCS_STUB_MODE="fail" PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" --local "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -ne 0 ]] && [[ "$(cat "${local_lk}")" == "OLD-LOCAL-SENTINEL" ]]; then
    ok "${t}/lock.sh: --local failure keeps old local lock"
  else
    fail "${t}/lock.sh: --local failure rc=${rc}, lock='$(cat "${local_lk}" 2>/dev/null)'"
  fi

  # no temp files left behind after failures
  left="$(find "${ROOT}/${t}/locks" -name ".${id}-*.repos.*" | wc -l)"
  [[ "${left}" -eq 0 ]] && ok "${t}/lock.sh: no temp files left after failures" \
                       || fail "${t}/lock.sh: ${left} temp files left behind"

  # successful export replaces the lock atomically
  VCS_STUB_MODE="ok" VCS_STUB_OUTPUT="${SMOKE_TMP}/valid.repos" \
    PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -eq 0 ]] && cmp -s "${exact}" "${SMOKE_TMP}/valid.repos"; then
    ok "${t}/lock.sh: success writes exact lock atomically"
  else
    fail "${t}/lock.sh: exact success rc=${rc}"
  fi

  VCS_STUB_MODE="ok" VCS_STUB_OUTPUT="${SMOKE_TMP}/valid.repos" \
    PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" --local "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -eq 0 ]] && cmp -s "${local_lk}" "${SMOKE_TMP}/valid.repos"; then
    ok "${t}/lock.sh: success writes local lock atomically"
  else
    fail "${t}/lock.sh: --local success rc=${rc}"
  fi

  # empty workspace cannot produce a lock
  rm -rf "${ws}"
  mkdir -p "${ws}/src"
  VCS_STUB_MODE="ok" VCS_STUB_OUTPUT="${SMOKE_TMP}/valid.repos" \
    PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -ne 0 ]] && cmp -s "${exact}" "${SMOKE_TMP}/valid.repos"; then
    ok "${t}/lock.sh: empty workspace refused, lock unchanged"
  else
    fail "${t}/lock.sh: empty workspace rc=${rc}"
  fi

  # P1: a PARTIAL workspace (some manifest repos missing) must refuse to
  # overwrite an existing exact lock, even though the export would succeed
  rm -rf "${ws}"
  (
    source "${t}/scripts/catalog.sh"
    manifest="$(catalog_get_field "${t}/catalog.tsv" "${id}" manifest)"
    last_name="$(manifest_repos "${t}/${manifest}" | tail -n1 | cut -f1)"
    mkdir -p "${ws}/src"
    while IFS=$'\t' read -r name _ _; do
      [[ -n "${name}" ]] || continue
      [[ "${name}" == "${last_name}" ]] && continue   # leave the last repo out
      mkdir -p "${ws}/src/${name}"
      : > "${ws}/src/${name}/README"
      git -C "${ws}/src/${name}" init -q . 2>/dev/null || true
    done < <(manifest_repos "${t}/${manifest}")
  )
  printf 'OLD-EXACT-SENTINEL\n' > "${exact}"
  VCS_STUB_MODE="ok" VCS_STUB_OUTPUT="${SMOKE_TMP}/valid.repos" \
    PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/lock.sh" "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -ne 0 ]] && [[ "$(cat "${exact}")" == "OLD-EXACT-SENTINEL" ]]; then
    ok "${t}/lock.sh: partial workspace refused, old exact lock preserved"
  else
    fail "${t}/lock.sh: partial workspace rc=${rc}, lock='$(cat "${exact}" 2>/dev/null)'"
  fi

  # missing workspace -> exit 2
  rm -rf "${ws}"
  "${BASH_CMD}" "${t}/scripts/lock.sh" "${id}" >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/lock.sh: missing workspace exits 2" \
                    || fail "${t}/lock.sh: missing workspace exit ${rc}, want 2"

  rm -f "${exact}" "${local_lk}"
  rm -rf "${ws}"
  SMOKE_CLEAN=()
done

echo "== 8. fetch.sh strict args and --update repo-set mismatch =="
for t in "${TREES[@]}"; do
  id="$(awk -F '\t' 'NR==2 {print $1}' "${t}/catalog.tsv")"

  for bad in "../${id}" "${id}/../x" "Bad-ID" "" "--bogus" "-x"; do
    "${BASH_CMD}" "${t}/scripts/fetch.sh" "${bad}" >/dev/null 2>&1
    rc=$?
    if [[ ${rc} -eq 2 ]]; then
      ok "${t}/fetch.sh: arg '${bad}' exits 2"
    else
      fail "${t}/fetch.sh: arg '${bad}' exit ${rc}, want 2"
    fi
  done

  "${BASH_CMD}" "${t}/scripts/fetch.sh" "${id}" extra >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/fetch.sh: extra positional arg exits 2" \
                    || fail "${t}/fetch.sh: extra positional arg exit ${rc}, want 2"

  "${BASH_CMD}" "${t}/scripts/fetch.sh" --update "${id}" extra >/dev/null 2>&1
  rc=$?
  [[ ${rc} -eq 2 ]] && ok "${t}/fetch.sh: --update + extra arg exits 2" \
                    || fail "${t}/fetch.sh: --update + extra arg exit ${rc}, want 2"

  # --update with a repo set that does not match the manifest must refuse
  # (offline: the refusal happens before any vcs call)
  ws="${t}/workspaces/${id}_ws"
  if [[ -e "${ws}" ]]; then
    echo "SKIP ${t}: ${ws} exists, leaving untouched"
    continue
  fi
  mkdir -p "${ws}/src"
  (
    source "${t}/scripts/catalog.sh"
    manifest="$(catalog_get_field "${t}/catalog.tsv" "${id}" manifest)"
    first_name="$(manifest_repos "${t}/${manifest}" | head -n1 | cut -f1)"
    mkdir -p "${ws}/src/${first_name}"
    : > "${ws}/src/${first_name}/README"
    # NOTE: deliberately NOT a git working tree, so the checkout is incomplete
    # for every manifest (also single-repo ones) and --update must refuse.
  )
  out="$("${BASH_CMD}" "${t}/scripts/fetch.sh" --update "${id}" 2>&1)"
  rc=$?
  if [[ ${rc} -ne 0 ]] && [[ "${out}" == *"does not match the manifest"* ]]; then
    ok "${t}/fetch.sh: --update repo-set mismatch refuses with actionable message"
  else
    fail "${t}/fetch.sh: --update mismatch rc=${rc}, out='${out}'"
  fi

  # P2a: --update must also refuse when src contains EXTRA independent git
  # checkouts (complete manifest set PLUS one unlisted repo)
  rm -rf "${ws}"
  mkdir -p "${ws}/src"
  (
    source "${t}/scripts/catalog.sh"
    manifest="$(catalog_get_field "${t}/catalog.tsv" "${id}" manifest)"
    while IFS=$'\t' read -r name _ _; do
      [[ -n "${name}" ]] || continue
      mkdir -p "${ws}/src/${name}"
      : > "${ws}/src/${name}/README"
      git -C "${ws}/src/${name}" init -q . 2>/dev/null || true
    done < <(manifest_repos "${t}/${manifest}")
    mkdir -p "${ws}/src/extra_repo_zz"
    : > "${ws}/src/extra_repo_zz/README"
    git -C "${ws}/src/extra_repo_zz" init -q . 2>/dev/null || true
  )
  out="$("${BASH_CMD}" "${t}/scripts/fetch.sh" --update "${id}" 2>&1)"
  rc=$?
  if [[ ${rc} -ne 0 ]] && [[ "${out}" == *"Extra checkouts"* ]]; then
    ok "${t}/fetch.sh: --update refuses extra git checkouts"
  else
    fail "${t}/fetch.sh: --update extra rc=${rc}, out='${out}'"
  fi

  # --update with no workspace at all must refuse too
  rm -rf "${ws}"
  out="$("${BASH_CMD}" "${t}/scripts/fetch.sh" --update "${id}" 2>&1)"
  rc=$?
  if [[ ${rc} -ne 0 ]] && [[ "${out}" == *"Import from scratch"* ]]; then
    ok "${t}/fetch.sh: --update without workspace refuses"
  else
    fail "${t}/fetch.sh: --update no-ws rc=${rc}, out='${out}'"
  fi
  rm -rf "${ws}"
done

echo "== 9. fetch.sh partial-checkout recovery (stub vcs, offline) =="
for t in "${TREES[@]}"; do
  id="$(awk -F '\t' 'NR==2 {print $1}' "${t}/catalog.tsv")"
  ws="${ROOT}/${t}/workspaces/${id}_ws"
  manifest="$("${BASH_CMD}" -c "source ${t}/scripts/catalog.sh; catalog_get_field ${t}/catalog.tsv ${id} manifest")"
  all_complete() {
    local bad=0
    while IFS=$'\t' read -r name _ _; do
      [[ -n "${name}" ]] || continue
      [[ -d "${ws}/src/${name}" ]] || bad=1
    done < <("${BASH_CMD}" -c "source ${t}/scripts/catalog.sh; manifest_repos ${t}/${manifest}")
    return "${bad}"
  }

  # 9a: a partially checked-out workspace is repaired to completion (rc 0)
  rm -rf "${ws}"
  mkdir -p "${ws}/src"
  (
    source "${t}/scripts/catalog.sh"
    first_name="$(manifest_repos "${t}/${manifest}" | head -n1 | cut -f1)"
    mkdir -p "${ws}/src/${first_name}"
    : > "${ws}/src/${first_name}/README"
    git -C "${ws}/src/${first_name}" init -q . 2>/dev/null || true
  )
  SMOKE_CLEAN+=("${ws}")
  VCS_STUB_MODE="ok" PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/fetch.sh" "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -eq 0 ]] && all_complete; then
    ok "${t}/fetch.sh: partial workspace repaired to complete (rc 0)"
  else
    fail "${t}/fetch.sh: partial workspace repair rc=${rc}, incomplete"
  fi

  # 9b: first fetch imports into staging and atomically moves into place
  rm -rf "${ws}"
  VCS_STUB_MODE="ok" PATH="${SMOKE_TMP}:${PATH}" "${BASH_CMD}" "${t}/scripts/fetch.sh" "${id}" >/dev/null 2>&1
  rc=$?
  if [[ ${rc} -eq 0 ]] && all_complete; then
    ok "${t}/fetch.sh: fresh fetch (staging + atomic mv) complete"
  else
    fail "${t}/fetch.sh: fresh fetch rc=${rc}, incomplete"
  fi
  left="$(find "${ws}" -name '.src-staging.*' 2>/dev/null | wc -l)"
  [[ "${left}" -eq 0 ]] && ok "${t}/fetch.sh: no staging leftovers" \
                        || fail "${t}/fetch.sh: ${left} staging leftovers"

  # 9c: an import that can never complete must FAIL loudly, not silently
  rm -rf "${ws}"
  (
    export VCS_STUB_MODE="never" VCS_STUB_STATE="${SMOKE_TMP}/state"
    export PATH="${SMOKE_TMP}:${PATH}"
    out="$("${BASH_CMD}" "${t}/scripts/fetch.sh" "${id}" 2>&1)"
    rc=$?
    if [[ ${rc} -ne 0 ]] && [[ "${out}" == *"incomplete"* ]]; then
      ok "${t}/fetch.sh: never-completing import fails loudly (rc ${rc})"
    else
      fail "${t}/fetch.sh: never-completing import rc=${rc}, out='${out}'"
    fi
  )

  # 9d: a transient partial failure is recovered by the retry path (rc 0)
  rm -rf "${ws}"
  rm -f "${SMOKE_TMP}/state"
  (
    export VCS_STUB_MODE="dropone" VCS_STUB_STATE="${SMOKE_TMP}/state"
    export PATH="${SMOKE_TMP}:${PATH}"
    "${BASH_CMD}" "${t}/scripts/fetch.sh" "${id}" >/dev/null 2>&1
    rc=$?
    if [[ ${rc} -eq 0 ]] && all_complete; then
      ok "${t}/fetch.sh: transient partial failure retried to completion"
    else
      fail "${t}/fetch.sh: dropone retry rc=${rc}"
    fi
  )

  rm -rf "${ws}"
  SMOKE_CLEAN=()
done

echo
echo "Smoke tests: ${PASSED} passed, ${FAILED} failed"
[[ "${FAILED}" -eq 0 ]]
