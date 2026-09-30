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

The copied DCLint release objects are not legitimate Gawk history. The copied
GitHub Release has been removed, while the inherited `v0.1.0` tag must still be
removed before the first Gawk release; the workflow fails closed while that tag
points at the inherited DCLint commit. Each Gawk release publishes the validated
descriptor and its SHA-256 checksum through a separate publication boundary.

See [ADR-002](ADR-002-publish-versioned-gawk-descriptor-release-assets.md).

### ADR-003: Use Alpine Gawk Major Version 5

The plugin installs Alpine's packaged Gawk with the `gawk=~5` constraint rather
than compiling an exact upstream release from source. Minor, patch, and Alpine
package revisions follow the pinned MegaLinter base image, while the major
version remains constrained to 5. Existing integration tests define the required
Gawk behavior and continue to exercise lint warnings, failures, and sandbox
enforcement through MegaLinter.

See [ADR-003](ADR-003-use-alpine-gawk-major-version-5.md).

<!-- adrctl-generated-footer -->

## Architecture Decision Records

* [ADR-001: Use Sandboxed GNU Awk 5.4.1 Linting](ADR-001-use-sandboxed-gawk-5.4.1-linting.md)
* [ADR-002: Publish Versioned Gawk Descriptor Release Assets](ADR-002-publish-versioned-gawk-descriptor-release-assets.md)
* [ADR-003: Use Alpine Gawk Major Version 5](ADR-003-use-alpine-gawk-major-version-5.md)
