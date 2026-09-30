# Decision Summary

This file provides concise summaries of the architecture decisions governing
`mega-linter-plugin-gawk`. The ADRs remain authoritative.

## Sandboxed GNU Awk Linting

`AWK_GAWK` runs each AWK source file with GNU Awk sandbox mode, closed stdin,
and a ten-second execution ceiling because Gawk has no parse-only lint mode.
Ordinary `--lint` diagnostics remain warnings, while syntax and fatal
diagnostics are errors, and user arguments may opt into `--lint=fatal`.
ADR-003 supersedes only ADR-001's original exact-version source-build decision.

See [ADR-001](adr/ADR-001-use-sandboxed-gawk-5.4.1-linting.md).

## Versioned Descriptor Release Assets

Plugin releases publish a generated `gawk.megalinter-descriptor.yml` and its
SHA-256 checksum after validating the exact generated descriptor through
MegaLinter. Publication is separated from source-executing validation, and the
published descriptor records both its release version and source commit. The
inherited DCLint release is gone, but its copied `v0.1.0` tag must still be
removed before the first Gawk release.

See [ADR-002](adr/ADR-002-publish-versioned-gawk-descriptor-release-assets.md).

## Alpine Gawk Major Version 5

The plugin installs Gawk from Alpine with `gawk=~5`, allowing package updates
within major version 5 while preventing an implicit move to a future major
version. Minor, patch, and Alpine revision selection follows the pinned
MegaLinter base image and its package repositories. Integration tests, rather
than an exact Gawk patch release, define the required runtime compatibility.

See [ADR-003](adr/ADR-003-use-alpine-gawk-major-version-5.md).
