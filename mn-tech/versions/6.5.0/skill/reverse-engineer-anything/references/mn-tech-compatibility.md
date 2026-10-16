# MN-Tech compatibility scope — REA 6.5.0

Validated on Windows x64 with Node 24.14.1 using synthetic local inputs, a separate REA package, a separate dependency directory and an isolated user profile. The actual stdio MCP server identified itself as REA 6.5.0, skill version 42, with 207 tools; the negotiated protocol was 2025-06-18. This is evidence about that isolated connection, not another chat's registered server.

## Confirmed core workflows

- `binary_session` identity and expected-version alignment; actual tool schemas were retrieved.
- `inspect_managed_artifact` and `inspect_managed_members` on a self-authored PE/CLI DLL: exact artifact SHA, one expected type, three methods, known arithmetic IL and a known call edge.
- `inspect_analysis_view`: a retained methods page returned two of three rows with a next offset and non-exhausted coverage.
- ZIP inventory through `open_binary`, `inspect_artifact` and `close_binary`: three expected members and the exact root hash.
- `analyze_javascript_application` through MCP and CLI: one parsed JS source, two relevant files, zero parse failures, same source digest. Application enumeration completed; semantic coverage remained `unknown` with six data-flow unknowns. Do not turn this into a full behavioral proof.
- Missing/invalid targets produced explicit errors. An intentionally wrong expected version produced `server_identity.alignment.state = mcp_server_restart_required` and `package_version_mismatch`; this is a result field, not necessarily an MCP `isError` response.
- Synthetic inputs remained unchanged and owned MCP servers exited normally.

## Canonical-skill diagnostic behavior

REA 6.5.0's `doctor --skill` compares installed skill contents with its bundled canonical files, in addition to checking metadata version and tool count. This adaptation intentionally changes SKILL.md, so the isolated diagnostic returned version 42, tool count 207, state `stale`, and exit code 1. A separate isolated profile with the unmodified upstream skill returned `aligned` and exit code 0 using the same runtime. Source inspection of SetupSkill/Doctor confirms the canonical-content condition.

This is an expected customization diagnostic, not proof of runtime incompatibility. It is also not a clean upstream health check. Verify the local manifest and documented differences; do not suppress the result or automatically overwrite the adaptation. If an authorized MCP registration repair is needed while preserving the customized skill, use `setup --client codex --skill=false --dry-run --json`, review the plan, then apply that same scope only when authorized. Without `--skill=false`, upstream setup may replace SKILL.md with its canonical version and remove the engineering routing from the active entry.

## Windows private-directory boundary

The first JavaScript analysis failed with EPERM when writing a temporary `.source` file under REA's private Windows runtime directory in the restricted execution environment. The same package, Node and fixture succeeded after an authorized execution-permission change. Source tracing found the Windows private-runtime/DACL path. This supports a restricted-token/private-directory incompatibility for that run; it is not a universal diagnosis for all EPERM errors.

Preserve the first failure and check the exact operation/path and caller policy. Do not patch REA, loosen directory ACLs, disable security controls, or automatically elevate. If the current client cannot run that operation within its authorized execution policy, report the boundary and continue unaffected work. A working CLI call does not prove that the current chat's MCP connection works.

## Optional SQLite prerequisite

On Node 24.14.1, `inspect_sqlite_database` returned `capability_unavailable` / `unsupported_provider` because `DatabaseSync.limits` was absent. REA 6.5.0 requests Node 24.15+ in the supported 24.x line, or a compatible Node 26+ runtime, for this capability. The package's general Node engine range alone is not sufficient to establish SQLite readiness.

SQLite inspection was not validated successfully in this environment. The current Node installation was preserved. Verify this capability separately in a suitable isolated runtime if needed.

## Not covered

Ghidra/Hopper/IDA/JADX engines, native decompilation, Android analysis, browser/runtime attachment, target execution, binary modification, desktop-client restart/discovery, and site operations were not tested. Advertising a tool does not prove its provider is available. Resolve prerequisites and authorization only for the route actually required.
