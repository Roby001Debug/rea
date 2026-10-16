# Reproducing the scoped compatibility checks

Use a new task directory and synthetic inputs. Do not point tests at a live skill directory, client profile, customer package or running application. Keep existing runtime/skill/configuration hashes before and after any authorized test. Retain failure records.

## Installation checks

From the bundle directory, choose a new absolute temporary path outside the bundle:

```powershell
.\tests\Test-Install.ps1 -TestRoot 'C:\temp\rea-synthetic-check-unique' -Apply
```

Use a different new directory for each shell. The ten checks cover preview, Unicode/space paths, copied hashes, unrelated siblings, existing-destination rejection, relative paths, altered and extra payloads, manifest traversal, junctions, and manual archive/restore. Nothing is removed automatically. Review the returned JSON and keep `result.json`.

## Runtime checks

Use an independently prepared, fixed REA 6.5.0 package and supported Node runtime. Keep its user profile, cache, temporary directory, dependencies and working directory separate. Disable dependency lifecycle scripts when preparing the test tree. Do not run setup against an existing client profile.

The following is a checklist of actual tool calls, not a script that changes configuration. Replace placeholders with absolute paths inside the test directory and use the live server's advertised schemas.

| Check | Call and independent expected result |
| --- | --- |
| Identity | `binary_session` with `expected_package_version: "6.5.0"`; package/server 6.5.0, alignment `aligned` |
| Version negative | Same call expecting `6.3.0`; inspect the nested alignment state and `package_version_mismatch`, not just `isError` |
| Managed identity | Compile [Fixture.cs](fixtures/Fixture.cs) to a library with an existing C# compiler; do not execute it. `inspect_managed_artifact` with `path` and `detail: "summary"`; returned SHA equals a separately calculated SHA-256 |
| Members | `inspect_managed_members` with the DLL path and `type_names: ["MnTechFixture.Decoder"]`; methods Transform, IsEnabled, Combine |
| Known code path | Transform has multiply by 2 then add 7; Combine calls Transform. Verify the IL and call edge against the source |
| Retained page | Request members with `detail: "summary"`, then `inspect_analysis_view` using the returned `parent_evidence_id`, view kind `managed-members`, collection `methods`, offset 0, limit 2; expect two of three rows and next offset 2 |
| Invalid/missing input | A plain-text file and a nonexistent DLL produce explicit target errors |
| JavaScript | `analyze_javascript_application` with `input_path` set to [js-app](fixtures/js-app), `format: "directory"`, `detail: "summary"`; two relevant files, one JS parse, zero parse errors; retain semantic unknowns |
| CLI fallback | Existing `rea analyze-javascript-application <absolute-js-app-path> --json`; source digest and parse statistics agree with MCP |
| Archive | Create a synthetic ZIP with package.json, index.js, config.json; open it, inspect its artifact graph, check exactly three member paths and the independently calculated root SHA, then close it |
| SQLite boundary | Create a small local synthetic SQLite database; `inspect_sqlite_database` either succeeds on a suitable runtime or explicitly reports the prerequisite gap. Do not count an unavailable result as successful SQLite inspection |
| Setup preview | With only an isolated profile, `rea doctor --client codex --json` should identify missing registration; `rea setup --client codex --dry-run --json` must list isolated targets and no applied actions |
| Exit/integrity | Close owned MCP processes normally; compare input and protected-installation hashes |

The fixtures are source only. Build outputs, downloaded packages, private directories and raw MCP logs belong in the local test directory and must not be added to the public bundle.
