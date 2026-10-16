# Validation — 2026-10-17

Result: **core static-workflow compatibility confirmed in an isolated Windows environment**, with the diagnostic and provider constraints below. This is not a full-platform certification or a clean canonical-skill doctor result.

The test used the official REA 6.5.0 tarball, an isolated dependency tree with lifecycle scripts disabled, Node 24.14.1 x64, separate user/cache/temp directories and synthetic local fixtures. The MCP server was launched as an owned child process over stdio; the active desktop client's registered server was not replaced or restarted.

| Area | Observed result |
| --- | --- |
| MCP handshake and catalog | REA 6.5.0, protocol 2025-06-18; 207 advertised tools retrieved, required schemas present |
| Managed PE/CLI | Known artifact SHA, expected type and three methods, multiply/add IL and Combine-to-Transform call edge matched source |
| Retained evidence view | Two of three method rows, next offset 2, non-exhausted coverage |
| ZIP | Exactly three expected synthetic members and matching root SHA |
| JavaScript MCP and CLI | Same input digest, two relevant files, one JS source parsed, zero parse failures; application enumeration complete |
| Negative inputs | Plain text and missing DLL rejected with structured target errors |
| Version mismatch | Wrong expected package version reported through nested alignment state and reason |
| Isolation and shutdown | Inputs unchanged; all three owned MCP sessions closed normally without forced termination |
| Setup preview | Planned targets confined to isolated profile; no applied actions or live configuration changes |
| Installation | Ten synthetic checks passed in Windows PowerShell 5.1 and ten in PowerShell 7.6.5, including non-overwrite and archive/restore |
| Skill format and sources | Skill-format validation passed; six upstream references and LICENSE retained without edits |

The retained runtime evidence passed 21 assertions. The SQLite assertion verifies its explicit prerequisite error only; it is not a successful SQLite feature test. Installer tests were rerun after final payload changes.

## Findings that affect use

1. **Canonical skill warning:** the customized skill was recognized as metadata version 42 / 207 tools but `doctor --skill` returned `stale` and exit code 1. An unmodified upstream control in another isolated profile returned `aligned` and exit code 0. Source tracing confirmed that upstream diagnostics require canonical byte equality. This expected customization warning remains visible; it was not suppressed. A separate `setup --skill=false --dry-run` check planned only MCP registration, preserving the skill. See [the compatibility guidance](skill/reverse-engineer-anything/references/mn-tech-compatibility.md).
2. **Windows execution policy:** the first JavaScript run under a restricted execution token failed with EPERM in the private runtime directory. With the same package, Node and fixture, an authorized execution-permission change allowed MCP and CLI analysis to complete. No runtime patch, ACL change or security-control change was made. The original failure is retained in local evidence.
3. **SQLite unavailable on this Node:** the tool explicitly required `DatabaseSync.limits`, available in Node 24.15+ in the supported 24.x line or a compatible Node 26+ runtime. SQLite success remains unverified; no installed Node upgrade was performed.
4. **Semantic coverage is bounded:** the JavaScript result retained `unknown` semantic coverage and six data-flow unknowns. Successful parsing is not proof of all runtime behavior.

Ghidra, Hopper, IDA, JADX, Android, runtime attachment, browser interaction, live target execution, desktop-client reconnect and site workflows were not exercised. The raw logs remain local because they contain machine paths. The published source fixtures and [compatibility checklist](tests/COMPATIBILITY.md) allow the bounded checks to be repeated without customer inputs.

The original 6.3.0 bundle is preserved on its original branch and also remains in the parent directory of the new versioned layout. Existing installations are not updated by publishing this bundle.
