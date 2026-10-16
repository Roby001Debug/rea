# MN-Tech engineering adaptation for REA 6.5.0

MN-Tech R03 portable adapts the upstream REA 6.5.0 skill to engineering work: current project rules, evidence provenance, original-file protection, scoped authorization, and actual MCP availability. It includes the 6.5.0 connection/recovery guide and keeps uncertainty and provider prerequisites explicit.

**Compatibility:** core static workflows passed isolated Windows tests using REA 6.5.0 and Node 24.14.1. This covers actual stdio MCP calls and a CLI fallback. It is not a claim that every one of the 207 advertised tools or every desktop client was exercised. See [validation](VALIDATION.md) and [Windows constraints](skill/reverse-engineer-anything/references/mn-tech-compatibility.md).

Because the skill is customized, upstream `doctor --skill` reports `stale` despite matching version/tool metadata. The unmodified upstream control reports `aligned`. This documented canonical-content difference must not trigger an automatic setup overwrite; preserve the adaptation with `--skill=false` when an authorized registration repair is required.

- [中文安装、备份和回退说明](INSTALL.zh-CN.md)
- [Source and integrity](PROVENANCE.md)
- [Synthetic compatibility checklist](tests/COMPATIBILITY.md)
- [Version selection and preserved 6.3.0 release](../../VERSIONS.md)
- [Skill entry](skill/reverse-engineer-anything/SKILL.md)

The installer defaults to a read-only preview. Applying it copies only the manifest-listed instruction files to a new skill directory. It refuses an existing destination, altered payloads, unlisted files and link-based paths. It does not install REA or Node, edit MCP configuration, or restart any application.

No customer data, vendor binaries, runtime dependencies, machine-specific configuration or raw analysis logs are included. Test fixtures are small synthetic source files. The upstream license and copyright notice are retained in [LICENSE](skill/reverse-engineer-anything/LICENSE); local changes are described in [NOTICE](skill/reverse-engineer-anything/NOTICE.md).
