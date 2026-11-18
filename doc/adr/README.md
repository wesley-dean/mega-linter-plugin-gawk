# Architecture Decisions

This directory contains accepted Architecture Decision Records for
`mega-linter-plugin-gawk`.

## Current Decisions

### ADR-001: Use Sandboxed GNU Awk 5.4.1 Linting

`AWK_GAWK` preserves ordinary `--lint` warnings as warnings rather than
forcing `--lint=fatal`. Because Gawk linting executes AWK source, the plugin
runs each file with sandbox mode, closed stdin, and a ten-second execution
ceiling. User arguments remain available for repositories that deliberately want
stricter Gawk behavior. ADR-003 supersedes ADR-001 only for Gawk installation
and exact-version selection.

See [ADR-001](ADR-001-use-sandboxed-gawk-5.4.1-linting.md).

### ADR-002: Publish Versioned Gawk Descriptor Release Assets

The copied DCLint `v0.1.0` tag and GitHub Release were removed before any Gawk
release. Each release publishes the validated descriptor and its SHA-256
checksum through a separate publication boundary, preserving the release
version and source commit. ADR-005 supersedes only the original `v0.1.0`
first-release version requirement after GitHub rejected reuse of that tag.

See [ADR-002](ADR-002-publish-versioned-gawk-descriptor-release-assets.md).

### ADR-003: Use Alpine Gawk Major Version 5

The plugin installs Alpine's packaged Gawk with the `gawk=~5` constraint rather
than compiling an exact upstream release from source. Minor, patch, and Alpine
package revisions follow the pinned MegaLinter base image, while the major
version remains constrained to 5. Existing integration tests define the required
Gawk behavior and continue to exercise lint warnings, failures, and sandbox
enforcement through MegaLinter.

See [ADR-003](ADR-003-use-alpine-gawk-major-version-5.md).

### ADR-004: Consolidate GitHub Actions Dependabot Version Updates

The weekly routine version-update group covers major, minor, and patch
versions while independent security updates and manual major review remain.

See [ADR-004](ADR-004-consolidate-github-actions-dependabot-maintenance.md).

### ADR-005: Use v0.1.1 After Immutable Release Tag Reservation

GitHub rejected `v0.1.0` because it had already named an immutable release,
even after the copied tag and release were deleted. The first legitimate
Gawk release will instead use `v0.1.1`, aligning the workflow seed and
consumer documentation. This supersedes only the original version number
in ADR-002, retaining the validated asset and separate-publication design.
Additional ref-creation restrictions remain a distinct potential blocker.

See [ADR-005](ADR-005-use-v0.1.1-after-immutable-release-tag-reservation.md).

<!-- adrctl-generated-footer -->

## Architecture Decision Records

* [ADR-001: Use Sandboxed GNU Awk 5.4.1 Linting](ADR-001-use-sandboxed-gawk-5.4.1-linting.md)
* [ADR-002: Publish Versioned Gawk Descriptor Release Assets](ADR-002-publish-versioned-gawk-descriptor-release-assets.md)
* [ADR-003: Use Alpine Gawk Major Version 5](ADR-003-use-alpine-gawk-major-version-5.md)
* [ADR-004: Consolidate GitHub Actions Dependabot Version Updates](ADR-004-consolidate-github-actions-dependabot-maintenance.md)
* [ADR-005: Use v0.1.1 After Immutable Release Tag Reservation](ADR-005-use-v0.1.1-after-immutable-release-tag-reservation.md)
