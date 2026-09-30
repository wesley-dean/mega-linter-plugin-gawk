# ADR-003: Use Alpine Gawk Major Version 5

Date: 2026-09-30

## Status

Accepted

## Supersedes

This ADR supersedes the portions of ADR-001 that require GNU Awk 5.4.1 to be
downloaded, checksum-verified, compiled from source, and verified as exactly
version 5.4.1. All execution-safety and lint-semantics decisions from ADR-001
remain in force.

## Context

The initial `AWK_GAWK` implementation built GNU Awk 5.4.1 from source inside
the MegaLinter plugin installation. That made the exact upstream release
explicit, but every fresh plugin installation had to install a compiler
toolchain, download a source archive, configure Gawk, compile it, install it, and
remove the temporary build dependencies.

MegaLinter 10.1.0 uses an Alpine 3.24 base image. Alpine provides Gawk as a
native package, and the Gawk 5.x package provides the behavior this plugin
requires: `--lint`, `--lint=fatal`, `--sandbox`, and `-f` source-file
execution.

The plugin's meaningful compatibility contract is behavioral. Its integration
tests exercise ordinary lint warnings, syntax failures, sandbox enforcement,
closed input, and the bounded per-file execution path.

## Decision Drivers

- Plugin initialization should avoid unnecessary source compilation.
- The plugin should remain on GNU Awk major version 5.
- Minor, patch, and Alpine package revisions should follow the MegaLinter base
  image and Alpine release rather than being independently maintained here.
- A future Gawk major version should not be adopted implicitly.
- Required lint and sandbox behavior should remain executable integration-test
  contracts.
- The installation should use the package manager native to MegaLinter's Alpine
  base image.

## Decision

The plugin SHALL install Gawk from Alpine using:

```text
apk add --no-cache 'gawk=~5'
```

The `=~5` constraint SHALL permit Gawk 5.x package versions and SHALL reject a
future major version. The descriptor SHALL verify that `gawk --version`
identifies GNU Awk major version 5 after installation.

The repository SHALL NOT independently pin a Gawk minor version, patch version,
or Alpine package revision. Those values SHALL follow the repositories and
release used by the pinned MegaLinter base image.

Release and integration validation SHALL continue to execute the generated
plugin descriptor through MegaLinter. The tested behavior, rather than an exact
Gawk patch release, SHALL define compatibility within Gawk major version 5.

## Alternatives Considered

### Continue Building GNU Awk 5.4.1 From Source

Rejected because the plugin does not require behavior unique to 5.4.1, while
source compilation adds repeated network, toolchain, build, and cleanup work to
plugin initialization.

### Install Alpine Gawk Without a Version Constraint

Rejected because an unqualified package dependency could silently adopt a future
Gawk major version with different behavior.

### Pin an Exact Alpine Gawk Package Revision

Rejected because it would duplicate version maintenance already performed by
the pinned MegaLinter and Alpine release while making ordinary package updates
more difficult.

### Publish a Custom MegaLinter Image With Gawk Preinstalled

Rejected for now because a one-package Alpine installation is small enough that
maintaining and distributing a separate image would add more operational
complexity than it removes.

## Consequences

### Positive

- Plugin installation no longer downloads or compiles Gawk source.
- Compiler and source-build dependencies are no longer required.
- Gawk package maintenance follows the MegaLinter base image and Alpine release.
- The plugin remains protected from an implicit Gawk major-version transition.
- Existing behavioral integration tests continue to guard the actual plugin
  contract.

### Negative

- A fresh plugin initialization still performs an Alpine package installation.
- Gawk minor and patch versions may change when the pinned MegaLinter base image
  changes.
- Reproducibility now depends on the pinned MegaLinter image and its package
  repositories rather than an independently checksummed Gawk source archive.

## Compatibility and Migration

The public `AWK_GAWK` linter key, descriptor path, lint semantics, sandbox
boundary, argument forwarding, and per-file timeout remain unchanged.

The release build no longer checks for a Gawk source archive name or source
archive SHA-256 because those artifacts are no longer part of the installation
path.

## Expected Outcome

`AWK_GAWK` keeps the tested GNU Awk 5 behavior it needs while making plugin
initialization substantially smaller and easier to maintain.
