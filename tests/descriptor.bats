#!/usr/bin/env bats

setup() {
  DESCRIPTOR="${BATS_TEST_DIRNAME}/../mega-linter-plugin-gawk/gawk.megalinter-descriptor.yml"
}

@test "descriptor exposes AWK_GAWK for AWK source files" {
  grep -Fq 'descriptor_id: "AWK"' "${DESCRIPTOR}"
  grep -Fq 'name: "AWK_GAWK"' "${DESCRIPTOR}"
  grep -Fq '  - ".awk"' "${DESCRIPTOR}"
}

@test "descriptor installs Alpine Gawk major version 5" {
  grep -Fq "apk add --no-cache 'gawk=~5'" "${DESCRIPTOR}"
  grep -Fq "gawk --version | grep -Eq '^GNU Awk 5" "${DESCRIPTOR}"
}

@test "descriptor identifies GNU upstream" {
  grep -Fq 'linter_repo: "https://git.savannah.gnu.org/cgit/gawk.git/"' "${DESCRIPTOR}"
  grep -Fq 'linter_url: "https://www.gnu.org/software/gawk/"' "${DESCRIPTOR}"
}

@test "descriptor uses file mode and gawk source-file semantics" {
  grep -Fq 'cli_lint_mode: "file"' "${DESCRIPTOR}"
  grep -Fq '      - "file"' "${DESCRIPTOR}"
  grep -Fq 'gawk --sandbox --lint' "${DESCRIPTOR}"
  grep -Fq -- '-f "${file}" </dev/null' "${DESCRIPTOR}"
}

@test "descriptor bounds execution and preserves warning semantics" {
  grep -Fq 'timeout -s TERM -k 2 10' "${DESCRIPTOR}"
  grep -Fq 'cli_lint_errors_count: "regex_count"' "${DESCRIPTOR}"
  grep -Fq '.*:[0-9]+:\\s*\\^' "${DESCRIPTOR}"
  grep -Fq 'cli_lint_warnings_count: "regex_count"' "${DESCRIPTOR}"
  grep -Fq 'warning:' "${DESCRIPTOR}"
}
