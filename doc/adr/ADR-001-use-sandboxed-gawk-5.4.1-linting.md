# ADR-001: Use Sandboxed GNU Awk 5.4.1 Linting

Date: 2026-09-29

## Status

Accepted

## Context

This repository provides MegaLinter linting for AWK source files using GNU Awk.
GNU Awk's `--lint` option warns about dubious and nonportable constructs, but
Gawk does not provide a parse-only lint mode. Invoking an AWK source file with
`-f` executes its `BEGIN` and `END` actions and may execute record-processing
rules when input is available.

Running arbitrary repository code as part of a lint pass creates a materially
different trust boundary from a static parser. An AWK program can otherwise call
`system()`, redirect output into files or commands, read other files and pipes,
load extensions, or alter the files supplied through `ARGV`.

GNU Awk provides `--sandbox`, which disables `system()`, redirected file and
pipe I/O, redirected `getline`, dynamic extensions, and adding new input files
through `ARGV`.

The reviewed upstream release is GNU Awk 5.4.1. The plugin downloads the
official GNU release archive and verifies SHA-256
`07f6f7342b7febe4313fc2c2542ad93d64fe20ad8717200109f105a826f5fd37` before building it.

## Decision Drivers

- `AWK_GAWK` should expose GNU Awk's real `--lint` diagnostics.
- Lint warnings should remain warnings unless a consumer deliberately chooses
  `--lint=fatal`.
- A lint pass should not grant unrestricted filesystem, process, or extension
  capabilities to repository-provided AWK source.
- Ordinary record-processing rules should not receive ambient stdin.
- Pathological or malicious AWK source should not be able to occupy a linter
  indefinitely.
- The reviewed GNU Awk version should be explicit and independently verified.
- User-supplied `AWK_GAWK_ARGUMENTS` should continue to reach Gawk.

## Decision

The public MegaLinter key SHALL be `AWK_GAWK`. The descriptor SHALL select
`.awk` files and lint them individually in MegaLinter `file` mode.

The default Gawk semantics SHALL be ordinary `--lint`, not `--lint=fatal`.
Diagnostics containing Gawk's `warning:` prefix SHALL be counted as MegaLinter
warnings. Gawk `error:`, `fatal:`, and syntax-error diagnostics SHALL be
counted as MegaLinter errors.

The lint invocation SHALL run GNU Awk with `--sandbox`, SHALL close stdin by
redirecting it from `/dev/null`, and SHALL enforce a ten-second execution
ceiling per source file. The source file SHALL be passed through Gawk's `-f`
option rather than interpreted as an inline AWK program or data file.

MegaLinter user arguments SHALL be forwarded to Gawk before `-f`. A consumer
MAY therefore add `--lint=fatal` when repository policy requires warnings to
fail the build.

The plugin SHALL build GNU Awk 5.4.1 from the GNU release archive at
`https://ftpmirror.gnu.org/gawk/gawk-5.4.1.tar.xz`. The installation
SHALL verify SHA-256 `07f6f7342b7febe4313fc2c2542ad93d64fe20ad8717200109f105a826f5fd37` before extraction and SHALL fail if the
installed `gawk --version` output does not identify GNU Awk 5.4.1.

## Alternatives Considered

### Invoke gawk --lint Directly Without Isolation

Rejected because linting would execute repository-provided AWK with unrestricted
process, filesystem, pipe, and extension capabilities.

### Use --lint=fatal By Default

Rejected because GNU Awk deliberately distinguishes lint warnings from fatal
errors. Consumers may opt into the stricter behavior through
`AWK_GAWK_ARGUMENTS`.

### Install Alpine's Packaged Gawk

Rejected for the reviewed initial integration because MegaLinter 10.1.0's Alpine
3.24 base currently carries an older Gawk release. Following the base package
would couple plugin behavior to the container distribution and would not provide
the reviewed 5.4.1 lint engine.

### Compile Without a Release Digest

Rejected because a versioned URL alone does not verify downloaded source bytes.

### Treat Gawk as a Parse-Only Static Analyzer

Rejected because that is not how `gawk --lint -f` behaves. Hiding execution
semantics would create a misleading security contract.

## Consequences

### Positive

- AWK source receives GNU Awk's native lint diagnostics.
- Nonfatal lint findings remain warnings.
- Gawk execution is meaningfully constrained during linting.
- Ambient input cannot unexpectedly drive record-processing rules.
- Infinite or unexpectedly expensive per-file execution is bounded.
- The reviewed Gawk source archive is cryptographically pinned.

### Negative

- Source compilation adds plugin initialization time.
- A valid AWK program whose `BEGIN` or `END` actions require a
  sandbox-prohibited operation may fail under this plugin.
- Sandbox mode mitigates but does not transform Gawk into a purely static parser.
- The ten-second execution ceiling may reject unusual AWK programs that perform
  expensive computation during `BEGIN` or `END`.

## Compatibility and Migration

This repository is new, so there is no prior `AWK_GAWK` compatibility contract
to preserve. Consumers requiring lint warnings to fail may configure
`AWK_GAWK_ARGUMENTS: ["--lint=fatal"]`.

## Expected Outcome

MegaLinter gains a useful GNU Awk lint integration with warning/error semantics
that match upstream behavior and a documented execution boundary suitable for CI.
