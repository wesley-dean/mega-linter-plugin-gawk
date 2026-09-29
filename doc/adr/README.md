# Architecture Decisions

This directory contains accepted Architecture Decision Records for
`mega-linter-plugin-gawk`.

## Current Decisions

### ADR-001: Use Sandboxed GNU Awk 5.4.1 Linting

`AWK_GAWK` lints `.awk` files with the reviewed GNU Awk 5.4.1
release and preserves ordinary `--lint` warnings as warnings rather than
forcing `--lint=fatal`. Because Gawk linting executes AWK source, the plugin
runs each file with sandbox mode, closed stdin, and a ten-second execution
ceiling. The GNU source archive is SHA-256 pinned before compilation, and user
arguments remain available for repositories that deliberately want stricter
Gawk behavior.

See [ADR-001](ADR-001-use-sandboxed-gawk-5.4.1-linting.md).

### ADR-002: Publish Versioned Gawk Descriptor Release Assets

The copied DCLint `v0.1.0` tag and GitHub Release are repository-copy artifacts
and must be deleted before the first Gawk release. The workflow fails closed
while the copied tag still points at its inherited DCLint commit, after which
Gawk begins a clean release lineage at `v0.1.0`. Each release publishes the
validated Gawk descriptor and its SHA-256 checksum through a separate
publication boundary.

See [ADR-002](ADR-002-publish-versioned-gawk-descriptor-release-assets.md).

<!-- adrctl-generated-footer -->

## Architecture Decision Records

* [ADR-001: Use Sandboxed GNU Awk 5.4.1 Linting](ADR-001-use-sandboxed-gawk-5.4.1-linting.md)
* [ADR-002: Publish Versioned Gawk Descriptor Release Assets](ADR-002-publish-versioned-gawk-descriptor-release-assets.md)
