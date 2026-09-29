# ADR-002: Publish Versioned Gawk Descriptor Release Assets

Date: 2026-09-29

## Status

Accepted

## Context

The new Gawk plugin repository was initialized from the DCLint plugin repository
to reuse its established governance, testing, and release machinery. The copy
also inherited an unrelated `v0.1.0` tag and GitHub Release containing DCLint
descriptor assets.

Those copied release objects do not describe this repository's Gawk plugin and
must not become part of its release lineage.

A MegaLinter plugin descriptor is executable configuration because it defines
installation commands and runtime behavior. Consumers therefore benefit from a
reviewed, versioned distribution boundary.

## Decision Drivers

- The Gawk repository should have a release history that describes Gawk only.
- The first legitimate plugin release should be `v0.1.0`.
- Accidental merge before copied-release cleanup should fail closed rather than
  silently advance the Gawk plugin to `v0.2.0`.
- Consumers should be able to pin immutable plugin descriptor versions.
- Exact distributed descriptor bytes should be validated before publication.
- Publication authority should remain separate from source-executing validation.

## Decision

The copied DCLint `v0.1.0` GitHub Release and tag SHALL be deleted before the
first Gawk release is published. They are repository-copy artifacts and do not
represent accepted Gawk history.

The release workflow SHALL explicitly reject the copied tag while it points to
commit `e244e7f7c8497da882c8abfcafe3d0d199573b7b`. This guard is a fail-closed migration safeguard and
prevents the version calculator from treating the copied DCLint tag as Gawk
history.

After cleanup, the first Gawk release SHALL be `v0.1.0`.

Every Gawk GitHub release SHALL include:

```text
gawk.megalinter-descriptor.yml
gawk.megalinter-descriptor.yml.sha256
```

The release build SHALL generate the distributed descriptor from the maintained
descriptor, record the release version and exact 40-character source commit SHA
in YAML comments, and generate the accompanying SHA-256 checksum.

Release validation SHALL exercise the generated descriptor itself, including
schema validation, checksum verification, GNU Awk installation, warning
semantics, syntax failure, and sandbox behavior through MegaLinter.

Only after validation succeeds SHALL a separate publication job receive the
release files. That job SHALL re-verify the exact file set and checksum before
creating the GitHub release.

Documentation SHALL recommend version-pinned release assets for reproducible CI
and MAY document `releases/latest/download/` for consumers that intentionally
follow the newest plugin release.

## Alternatives Considered

### Keep the Copied DCLint v0.1.0 Release

Rejected because it falsely represents unrelated software as part of the Gawk
plugin's release history.

### Begin Gawk at v0.2.0

Rejected because the inherited `v0.1.0` is accidental repository-copy state,
not a legitimate predecessor release.

### Rewrite the Copied v0.1.0 Release In Place

Rejected because retaining the inherited release object makes provenance harder
to audit and risks leaving unrelated DCLint assets or metadata behind.

### Continue Recommending main

Rejected because branch content is mutable and does not represent an explicit
release boundary.

## Consequences

### Positive

- Gawk starts with a clean and truthful release lineage.
- Accidental inherited-tag use fails closed.
- Consumers can pin exact descriptor releases.
- Published bytes are validated before release.
- Release assets include integrity and source-provenance information.

### Negative

- Initial repository setup requires one manual GitHub cleanup step because the
  available repository connector cannot delete tags or releases.
- Release automation remains more involved than consuming the descriptor from
  `main`.

## Compatibility and Migration

Before merging the initial Gawk plugin PR, delete both the copied DCLint
`v0.1.0` GitHub Release and its `v0.1.0` tag. No legitimate Gawk consumer
depends on those copied objects.

## Expected Outcome

The Gawk plugin begins at `v0.1.0` with a clean, auditable distribution history
and the same validated release-asset model used by the other maintained plugins.
