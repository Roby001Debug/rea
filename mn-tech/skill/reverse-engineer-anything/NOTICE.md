# MN-Tech REA engineering adaptation

Upstream: https://github.com/morluto/rea

Instruction baseline: `rea-agents` 6.3.0, skill metadata version 34 / tool_count 139.
The npm release records upstream commit `74cf9e1401fcd89482fe39c27cc898f5858e9b72`.
Metadata counts describe that source snapshot, not the tools in a future session.

The original MIT license and copyright notice are preserved in [LICENSE](LICENSE).
The MN-Tech additions are provided under the same MIT terms. This is a downstream
adaptation, not an upstream release or endorsement.

R01 (2026-10-10) added engineering task selection, project rules, authorization
and evidence boundaries, Codex invocation metadata, and conditional delegation.
R02 portable (2026-10-17) removes assumptions about this computer's installation,
states the runtime baseline, and supplies a separate portable distribution with
installation and recovery instructions.

Changed from the released skill: `SKILL.md`.
Added: this notice, the license copy, `agents/openai.yaml`, and
`references/local-engineering-rules.md`. The five upstream analysis references
are byte-for-byte copies of the npm 6.3.0 release.

No runtime code, provider code, binary modification, or licensing behavior is
changed by this instruction bundle. Future upstream setup may replace the skill;
archive the existing folder outside active skill discovery before an upgrade.
