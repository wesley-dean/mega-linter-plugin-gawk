# ADR-005: Use v0.1.1 After Immutable Release Tag Reservation

Date: 2026-11-18

## Status

Accepted

## Supersedes

This ADR supersedes only ADR-002's requirement that the first legitimate
Gawk release use `v0.1.0`. ADR-002's release-artifact, integrity,
validation, source-provenance, and separate-publication requirements
remain in force. ADR-001, ADR-003, and ADR-004 are unchanged.

## Context

The Gawk plugin repository was initialized from a different MegaLinter
plugin and inherited a DCLint `v0.1.0` GitHub Release and tag.
ADR-002 required deletion of those unrelated release objects and
selection of `v0.1.0` for Gawk's first legitimate release.
Both copied objects were confirmed absent on 2026-09-30.

On 2026-11-18, Versioning workflow run
[44368811261](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/runs/44368811261)
successfully validated the Gawk descriptor, produced its two release
assets, and verified their checksum. The publication job then failed
while creating the `v0.1.0` GitHub Release with errors including:

```text
Cannot create ref due to creations being restricted.
tag_name was used by an immutable release
Published releases must have a valid tag
```

GitHub documents that once an immutable release is deleted, its tag
can be deleted but the tag name cannot be reused. Therefore the
absence of an existing `v0.1.0` tag or release does not make that
version name available again.

Reference: [GitHub immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases).

The error also mentions a ref-creation restriction. Whether a
separate repository or organizational rule will block other tag names
has not been established by this failure alone.

## Decision Drivers

- Preserve the verified release-artifact and provenance contract.
- Avoid reusing a tag name reserved by GitHub after an immutable release.
- Make the first valid Gawk version explicit in automation and examples.
- Preserve the historical rationale of ADR-002 and its other decisions.
- Avoid weakening immutable-release, validation, or publication controls.
- Keep changes limited to release bootstrap and documentation.

## Assumptions

- `v0.1.1` is not currently present as a Git tag or GitHub Release.
  A historical immutable-release reservation cannot be ruled out
  solely by checking currently visible repository objects.
- The version calculator uses `initial_version` as the starting
  version while no applicable version tags are present.
- Any independent tag-creation restrictions will be diagnosed if the
  `v0.1.1` publication attempt fails; this decision does not bypass them.

## Decision

The first legitimate Gawk release SHALL use `v0.1.1` instead of
`v0.1.0`. The Versioning workflow SHALL set
`initial_version: 0.1.1` with its existing `v` tag prefix and
`create_tag: false` setting. User-facing release examples SHALL
reference `v0.1.1`.

The `v0.1.0` name SHALL NOT be retried, force-recreated, or used as
the published Gawk release version. The repository SHALL continue to
validate exact descriptor bytes and their SHA-256 checksum before
publication, transferring the artifacts to a separate publication
job under ADR-002.

If `v0.1.1` publication also fails due to a ref-creation restriction,
the failure SHALL remain visible and the applicable repository or
organizational rules SHALL be investigated before any change to
release permissions or tag-creation controls.

## Alternatives Considered

### Retry v0.1.0

Rejected because GitHub explicitly reports that the name was used
by an immutable release. Removing the visible tag or release does
not release its name for reuse.

### Disable or Bypass Release Immutability

Rejected because release integrity and provenance are meaningful
security controls, and disabling them would not retroactively free
a reserved immutable-release tag name.

### Start at v0.2.0

Technically possible if available, but rejected because a patch-level
increment to `v0.1.1` communicates the bootstrap correction with
less version-number discontinuity.

### Publish Assets Directly From main

Rejected because mutable branch content does not provide the versioned,
reviewed distribution boundary required by ADR-002.

## Consequences

### Positive

- The workflow no longer requests the known-reserved `v0.1.0` name.
- Documentation and the release-version seed describe the same release.
- The validated artifact and independent publication boundaries remain.
- The conflict with the original first-release requirement is recorded.

### Negative

- The first Gawk release will be numbered `v0.1.1` despite there
  having been no legitimate `v0.1.0` Gawk release.
- This change alone cannot prove that another tag name can be created
  under the repository's effective rules.
- Release publication still requires a successful workflow after merge.

## Compatibility and Migration

No published Gawk `v0.1.0` assets exist for consumers to migrate.
Documentation examples that previously referenced `v0.1.0` will
refer to `v0.1.1`. The public `AWK_GAWK` linter key, descriptor
path, lint behavior, and artifact filenames remain unchanged.

## Expected Outcome

After the reviewed change reaches `main`, the release workflow
attempts to publish validated Gawk assets under `v0.1.1`.
Successful publication must be confirmed from the actual workflow
and release state; the version change does not guarantee it.
