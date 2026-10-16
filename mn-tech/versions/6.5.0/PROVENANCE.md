# Provenance and integrity

This instruction bundle uses the published `rea-agents@6.5.0` npm package as its source. It is maintained separately from upstream runtime code.

| Item | Value |
| --- | --- |
| Upstream repository | [morluto/rea](https://github.com/morluto/rea) |
| Exact package | [rea-agents 6.5.0](https://www.npmjs.com/package/rea-agents/v/6.5.0) |
| Release tarball | [Official npm tarball](https://registry.npmjs.org/rea-agents/-/rea-agents-6.5.0.tgz) |
| Tarball SHA-256 | `531717a06e92ca651aab52691190f916fac044272c01f875e22c5e293218e699` |
| Tarball SHA-1 | `7ea5e6f669bc18c45dbf5dba653edaa1ada07ab3` |
| npm integrity | `sha512-C6BG7LyrAdR74mSjertM6PrxJkcNZ2bfQNOJornPo9erDEp2tyPRVYPnV5Yodr+1RqewCQla68WulXlVnveD+A==` |
| Upstream Git tag | [rea-agents-6.5.0](https://github.com/morluto/rea/tree/rea-agents-6.5.0), commit `3b79af28e80785afce9f5998d8f03289402a1847` |
| Skill metadata | version `42`, tool_count `207` |
| Adaptation | MN-Tech engineering R03 portable, 2026-10-17 |

The registry's SHA-512 and SHA-1 were checked against the downloaded bytes. The Git tag was checked independently. The npm metadata did not supply `gitHead`; the tag commit is not claimed to be an npm-provided build identity.

All six upstream reference files and LICENSE are preserved byte for byte from the release tarball. SKILL.md has only the documented local routing, description, metadata and collaboration changes. The engineering-rules reference, agent metadata, installer and installer tests are reused from the preserved R02 bundle. A compatibility reference, synthetic source fixtures and release documentation are added here.

[manifest.json](manifest.json) lists every installable instruction file with SHA-256. Git's `.gitattributes` disables newline conversion in this bundle so a Windows checkout retains those bytes. The manifest protects the skill payload; use the Git commit identity when checking scripts and documentation too.

The isolated test used the existing Node executable, a separate package directory, a private dependency tree with a lockfile, and a separate user profile/cache/temp tree. Dependency lifecycle scripts were disabled. No installed runtime, client configuration or active skill directory was used as a write destination. Raw logs and the dependency lock remain in local validation records because they include machine paths; they are not part of this public instruction bundle.
