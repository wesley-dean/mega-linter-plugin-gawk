# mega-linter-plugin-gawk

[![MegaLinter](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/workflows/megalinter.yml/badge.svg)](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/workflows/megalinter.yml)
[![Dependabot Updates](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/workflows/dependabot/dependabot-updates)
[![Scorecard supply-chain security](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/workflows/scorecard.yml/badge.svg)](https://github.com/wesley-dean/mega-linter-plugin-gawk/actions/workflows/scorecard.yml)

This repository provides the `AWK_GAWK` MegaLinter plugin for AWK source files.
It uses GNU Awk's `--lint` diagnostics to report dubious and nonportable AWK
constructs while preserving Gawk's distinction between warnings and errors.

## MegaLinter Configuration

For reproducible CI and production workflows, pin the plugin to a release:

```yaml
PLUGINS:
  - "https://github.com/wesley-dean/mega-linter-plugin-gawk/releases/download/v0.1.0/gawk.megalinter-descriptor.yml"

ENABLE_LINTERS:
  - "AWK_GAWK"
```

When deliberately following the newest released plugin version:

```yaml
PLUGINS:
  - "https://github.com/wesley-dean/mega-linter-plugin-gawk/releases/latest/download/gawk.megalinter-descriptor.yml"
```

The plugin selects files ending in `.awk` and invokes each file independently.

## Lint Semantics

The default behavior corresponds to GNU Awk's ordinary `--lint` mode:

- lint diagnostics are reported as MegaLinter warnings;
- syntax errors and fatal Gawk errors are MegaLinter errors; and
- warnings alone do not make the linter fail.

To make GNU Awk lint warnings fatal, add the documented Gawk override:

```yaml
AWK_GAWK_ARGUMENTS:
  - "--lint=fatal"
```

User arguments are forwarded to Gawk after the plugin's default `--lint`
selection and before the source file.

## Execution Safety

GNU Awk does not provide a parse-only lint mode. Running `gawk --lint -f
script.awk` executes `BEGIN` and `END` actions even when there is no input.
The plugin therefore uses a constrained invocation:

```text
gawk --sandbox --lint ... -f script.awk </dev/null
```

The wrapper also terminates any single AWK file that runs for more than ten
seconds.

GNU Awk sandbox mode disables `system()`, redirected file/pipe I/O, redirected
`getline`, dynamic extensions, and adding new input files through `ARGV`.
Closing stdin prevents ordinary record-processing rules from receiving ambient
input.

This is deliberately safer than unrestricted program execution, but it has a
compatibility consequence: an otherwise valid AWK program that intentionally
performs a sandbox-prohibited operation from a `BEGIN` or `END` action may fail
the lint run. That tradeoff is recorded in ADR-001.

## GNU Awk Version

The plugin installs Gawk from the Alpine package repositories used by the
MegaLinter base image:

```text
apk add --no-cache 'gawk=~5'
```

The fuzzy package constraint accepts Gawk 5.x while rejecting a future major
version. The exact minor, patch, and Alpine package revision therefore follow
the pinned MegaLinter base image and its Alpine release rather than requiring a
source build inside every plugin initialization.

The integration suite validates the Gawk behavior on which `AWK_GAWK` depends:
ordinary lint warnings, syntax failures, sandbox enforcement, and the configured
execution boundary. ADR-003 records this versioning and installation policy.

## GNU Awk Documentation

- [GNU Awk home](https://www.gnu.org/software/gawk/)
- [Command-line options](https://www.gnu.org/software/gawk/manual/html_node/Options.html)
- [GNU Awk exit status](https://www.gnu.org/software/gawk/manual/html_node/Exit-Status.html)

## Releases

Each plugin release publishes:

```text
gawk.megalinter-descriptor.yml
gawk.megalinter-descriptor.yml.sha256
```

The distributed descriptor records the plugin release version and exact source
commit that produced it. Release validation exercises the generated descriptor
through MegaLinter before publication.

This repository was initialized by copying another plugin repository. The copied
DCLint GitHub Release has been removed, but the copied `v0.1.0` tag must also
be removed before the first Gawk release is published. The release workflow
fails closed while that tag still points at the inherited DCLint commit.

## Development

Behavioral fixtures cover four distinct contracts:

```text
good.awk            clean AWK source
lint-warning.awk    nonfatal gawk --lint diagnostic
syntax-error.awk    syntax failure
sandbox-system.awk  prohibited attempted side effect
```

Useful targets are:

```bash
make test
make validate
make build
make validate-release
make integration-test
make clean
```

For a local release-style build:

```bash
make build VERSION=0.1.0 BUILD_REF="$(git rev-parse HEAD)"
```

## Repository Governance

This repository adopts released engineering standards from
[`wesley-dean/coding_standards`](https://github.com/wesley-dean/coding_standards).
The complete pinned snapshot is committed beneath `doc/standards/`, while
`.codingstandardrc` records the adopted release and verified archive digest.

Applicable files beneath `doc/standards/` are project requirements, subject to
accepted repository-specific ADRs and explicit local policy. Imported standards
are managed as a release snapshot and are not edited locally to create
project-specific exceptions.
