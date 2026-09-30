#!/usr/bin/env bash
# shellcheck shell=bash
## @file tests/megalinter.bash
## @brief Exercises GNU Awk linting through a real MegaLinter plugin load.
## @details
## Runs the generated descriptor against deterministic AWK fixtures. The clean
## and lint-warning fixtures must complete successfully while preserving the
## lint warning as a MegaLinter warning. Syntax errors and sandbox-prohibited
## side effects must fail. The sandbox test also verifies that the attempted
## filesystem side effect did not occur.
##
## MegaLinter requires local plugin descriptors beneath a path containing
## `mega-linter-plugin-`. The selected descriptor is copied byte-for-byte into
## a temporary staging directory satisfying that convention.

set -euo pipefail

readonly GAWK_EX_NOINPUT=66
readonly GAWK_EX_SOFTWARE=70
readonly MEGALINTER_IMAGE="${MEGALINTER_IMAGE:-ghcr.io/oxsecurity/megalinter-ci_light:v10.1.0}"
readonly GAWK_DESCRIPTOR="${GAWK_DESCRIPTOR:-mega-linter-plugin-gawk/gawk.megalinter-descriptor.yml}"
readonly PLUGIN_STAGE_DIR="test-results/mega-linter-plugin-gawk-release"
readonly PLUGIN_STAGE_DESCRIPTOR="${PLUGIN_STAGE_DIR}/gawk.megalinter-descriptor.yml"
readonly PASS_OUTPUT="test-results/gawk-pass.log"
readonly FAIL_OUTPUT="test-results/gawk-fail.log"
readonly SANDBOX_MARKER="test-results/gawk-sandbox-escaped"

## @fn stage_plugin_descriptor()
## @brief Stages the selected descriptor where MegaLinter accepts local plugins.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## A diagnostic is written if staging or byte verification fails.
##
## @returns Nothing is written to STDOUT.
## @retval 0 The descriptor was staged and verified.
## @retval 66 The selected descriptor is not readable.
## @retval 70 The descriptor could not be staged or verified.
stage_plugin_descriptor() {
  if [[ ! -r ${GAWK_DESCRIPTOR} ]]; then
    printf 'Descriptor is not readable: %s\n' "${GAWK_DESCRIPTOR}" >&2
    return "${GAWK_EX_NOINPUT}"
  fi

  if ! mkdir -p -- "${PLUGIN_STAGE_DIR}"; then
    printf 'Unable to create plugin staging directory: %s\n' "${PLUGIN_STAGE_DIR}" >&2
    return "${GAWK_EX_SOFTWARE}"
  fi

  if ! cp -- "${GAWK_DESCRIPTOR}" "${PLUGIN_STAGE_DESCRIPTOR}"; then
    printf 'Unable to stage plugin descriptor: %s\n' "${GAWK_DESCRIPTOR}" >&2
    return "${GAWK_EX_SOFTWARE}"
  fi

  if ! cmp -s -- "${GAWK_DESCRIPTOR}" "${PLUGIN_STAGE_DESCRIPTOR}"; then
    printf '%s\n' 'Staged plugin descriptor differs from the selected descriptor.' >&2
    return "${GAWK_EX_SOFTWARE}"
  fi
}

## @fn run_megalinter()
## @brief Runs AWK_GAWK through MegaLinter against an explicit JSON file list.
## @param files_json JSON array of repository-relative AWK fixture paths.
##
## @par STDIN
## Nothing is read from STDIN.
## @par STDOUT
## MegaLinter writes its ordinary console report to STDOUT.
## @par STDERR
## MegaLinter and Docker diagnostics may be written to STDERR.
##
## @returns MegaLinter's console report.
## @retval 0 The selected fixtures contain no Gawk errors.
## @note Non-zero Docker, plugin-install, Gawk, or MegaLinter statuses are
## propagated unchanged.
run_megalinter() {
  local files_json=$1
  local plugin_uri="file://${PLUGIN_STAGE_DESCRIPTOR}"

  docker run \
    --rm \
    -v "${PWD}:/tmp/lint" \
    -w /tmp/lint \
    -e VALIDATE_ALL_CODEBASE=true \
    -e DISABLE_ERRORS=false \
    -e PRINT_ALPACA=false \
    -e SARIF_REPORTER=false \
    -e REPORT_OUTPUT_FOLDER=/tmp/megalinter-reports \
    -e "PLUGINS=[\"${plugin_uri}\"]" \
    -e ENABLE_LINTERS='["AWK_GAWK"]' \
    -e "MEGALINTER_FILES_TO_LINT=${files_json}" \
    "${MEGALINTER_IMAGE}"
}

stage_plugin_descriptor
rm -f -- "${SANDBOX_MARKER}"

if ! run_megalinter '["tests/fixtures/good.awk","tests/fixtures/lint-warning.awk"]' > "${PASS_OUTPUT}" 2>&1; then
  cat "${PASS_OUTPUT}"
  printf '%s\n' 'Expected clean and lint-warning AWK fixtures to complete without errors.' >&2
  exit 1
fi

cat "${PASS_OUTPUT}"

grep -Fq -- "tests/fixtures/good.awk" "${PASS_OUTPUT}"
grep -Fq -- "tests/fixtures/lint-warning.awk" "${PASS_OUTPUT}"
grep -Eq '\|.*AWK.*\|.*gawk.*\|.*file.*\|[[:space:]]*2[[:space:]]*\|.*\|[[:space:]]*0[[:space:]]*\|.*\|[[:space:]]*[1-9][0-9]*[[:space:]]*\|' "${PASS_OUTPUT}"

if run_megalinter '["tests/fixtures/syntax-error.awk","tests/fixtures/sandbox-system.awk"]' > "${FAIL_OUTPUT}" 2>&1; then
  cat "${FAIL_OUTPUT}"
  printf '%s\n' 'Expected syntax and sandbox-prohibited AWK fixtures to fail.' >&2
  exit 1
fi

cat "${FAIL_OUTPUT}"

grep -Fq -- "tests/fixtures/syntax-error.awk" "${FAIL_OUTPUT}"
grep -Fq -- "tests/fixtures/sandbox-system.awk" "${FAIL_OUTPUT}"
grep -Eq 'syntax error|fatal:' "${FAIL_OUTPUT}"

if [[ -e ${SANDBOX_MARKER} ]]; then
  printf '%s\n' 'Gawk sandbox test escaped and modified the workspace.' >&2
  exit 1
fi
