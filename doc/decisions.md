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
copied DCLint release and tag were removed, but the original `v0.1.0`
release seed was later superseded by ADR-005 after GitHub rejected reuse of
the immutable release's tag name.

See [ADR-002](adr/ADR-002-publish-versioned-gawk-descriptor-release-assets.md).

## Initial Release Version After Immutable Tag Reservation

GitHub rejected publication under `v0.1.0` because the tag name had already
been used by an immutable release, despite removal of the copied tag and
release. The first legitimate Gawk release therefore uses `v0.1.1`, with
both the workflow's initial version and documentation examples updated.
This partially supersedes ADR-002's first-version requirement while
preserving its release validation, checksum, and publication controls.
A separate ref-creation restriction, if any, still requires investigation.

See [ADR-005](adr/ADR-005-use-v0.1.1-after-immutable-release-tag-reservation.md).

## Alpine Gawk Major Version 5

The plugin installs Gawk from Alpine with `gawk=~5`, allowing package updates
within major version 5 while preventing an implicit move to a future major
version. Minor, patch, and Alpine revision selection follows the pinned
MegaLinter base image and its package repositories. Integration tests, rather
than an exact Gawk patch release, define the required runtime compatibility.

See [ADR-003](adr/ADR-003-use-alpine-gawk-major-version-5.md).

## ADR-004: Consolidate GitHub Actions Dependabot Version Updates

The repository retains weekly routine GitHub Actions version updates with
a seven-day cooldown and groups eligible major, minor, and patch versions.
Security updates remain separate, and groups containing major updates stay
outside the existing non-major-only auto-merge path. Existing Gawk sandbox,
version-5, release verification, and publication decisions remain unchanged.

See [ADR-004](adr/ADR-004-consolidate-github-actions-dependabot-maintenance.md).
