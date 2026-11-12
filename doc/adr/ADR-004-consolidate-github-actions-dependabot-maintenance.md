# ADR-004: Consolidate GitHub Actions Dependabot Version Updates

Date: 2026-11-12

## Status

Accepted

## Decision

Preserve the existing weekly GitHub Actions version-update schedule and
seven-day cooldown. Replace the minor/patch-only group with a wildcard
`actions-version-updates` group using `applies-to: version-updates`
and `patterns: ["*"]` without an `update-types` restriction.
Eligible major, minor, and patch versions can be proposed together.
Security updates remain independently handled and must not be delayed.
Retain the current non-major-only Dependabot auto-merge guard; a grouped PR
containing any major version must receive targeted manual review.

## Context, Assumptions, and Drivers

Minor/patch-only grouping can create separate major version PRs, increasing
maintainer review effort. The verified `coding_standards@v3.2.0` release
recommends balanced weekly per-ecosystem grouping with seven-day cooldowns.

This plugin executes untrusted AWK in Gawk's sandbox with closed stdin,
ten-second timeout, and ordinary lint warning semantics under ADR-001.
ADR-003 supersedes only the source-install contract, selecting Alpine
`gawk=~5`. ADR-002 requires validated immutable descriptor releases and
separate publication authority. Those decisions are not modified.

The only configured Dependabot ecosystem is GitHub Actions. Existing checks,
credentials, release authority, and workflow permissions are unchanged.
Effective code-owner reviews, branch protections, and Dependabot security
settings require separate live verification; YAML does not establish them.

## Alternatives and Consequences

Keeping minor/patch-only grouping was rejected because it perpetuates
separate routine major PRs. Monthly schedules and longer cooldowns were
rejected without evidence that delayed updates are appropriate. Automatic
merge of major-containing groups was rejected for compatibility and
supply-chain risk. Closing existing PRs upon configuration change was
rejected because no replacement evidence exists.

Broad grouping may reduce PR count but cannot guarantee one PR weekly.
A broken or privileged action can complicate diagnosis of grouped failures;
review each dependency's migration notes, permissions, CI coverage, and
release impact. Isolate sensitive updates only through reviewed exceptions,
rather than ignoring them. Existing Dependabot PR #8 stays open until
actually superseded with appropriate test evidence.

## Expected Outcomes, Compatibility, and Verification

Observe later Dependabot runs, major-group metadata, and CI coverage.
Confirm no major-containing group enters the existing non-major auto-merge
path, and independently verify GitHub security settings. This change does
not alter AWK lint behavior, sandbox boundaries, package version selection,
plugin keys, descriptor release artifacts, or user-facing interfaces.

## Related Decisions

ADR-001 governs sandboxed linting; ADR-002 governs validated release
assets and publication; ADR-003 governs Alpine Gawk major version 5.
All remain authoritative.
