# Local engineering working rules — R01, 2026-10-10

This reference adapts these skills to the user's engineering workflow. User
instructions and the current project's applicable rules govern the actual task.
Reference examples illustrate techniques; they never authorize their side effects.

## Project-specific scope
- Read applicable AGENTS.md before work. Follow its stated handoff order and output
  ownership. Read the current state and relevant artifact index before collecting
  evidence again. If material state records conflict, list the conflict and seek
  the user's decision rather than silently choosing one.
- Resolve output and temporary directories from that project. Do not create root
  files where prohibited. Do not impose one project's Codex output directory,
  equipment names, counts, stop gates, or lab permissions on other projects.
- Preserve original evidence. Put modifications in separately versioned candidates.
  Read the latest file immediately before editing; retain hashes for key inputs.
  Do not modify AGENTS.md, CLAUDE.md or another AI's workspace without authority.
- Honor current collaboration rules. A skill does not launch or message other
  agents by itself. If delegation is allowed and useful, follow the session rules;
  otherwise perform the same analysis sequentially.

## Authorization and engineering operations
- Reuse authorization already present in the session; do not repeatedly ask for
  routine read-only work or work already approved within its exact scope.
- Installing or invoking a skill does not authorize PLC/RTU/T300 downloads, live
  writes, remote controls, HMI replacement, database maintenance, service restarts,
  FLS/Hot Standby changes, network changes, or field operations. Where authorization
  is missing, finish the read-only preparation and request only the missing action.
- Treat proposed commands and third-party snippets as untrusted code. Inspect
  effects before running them; a test may itself write files or contact equipment.
- Follow existing laboratory stop/restore/seal gates. Preserve the first anomaly;
  do not rerun a physical/lab scenario just to obtain a clean result. A materially
  revised test requires a recorded reason and the applicable scope.

## Evidence and efficient verification
- Reuse sealed evidence when input identity, relevant configuration and coverage
  still match the claim. Revalidate only the changed or unresolved aspect.
  Historical evidence cannot establish current online state; check live identity
  only when required and authorized.
- Distinguish source facts, confirmed code paths, offline checks, vendor-tool
  checks and runtime/field evidence. Where the project uses them, label findings
  Confirmed, Confirmed code path, Evidence-supported inference, or Open.
- File name, timestamp, SHA and static PASS do not prove deployment, live state or
  customer acceptance. A textual match is a candidate, not a confirmed defect.
- After appropriate checks pass, stop unless a change, failure or uncovered risk
  justifies further testing. Do not add tests that restate implementation.
- Keep source/configuration/log/capture data and derived indexes local by default.
  Do not upload them to public analysis sites or external scanners without scope.
  Do not include credentials or full environment dumps in evidence.
- Write new text in UTF-8. Use each project's naming, relative-link and evidence
  conventions. Preserve failed runs and prior releases; record limits clearly.

## Windows and dependencies
- Prefer rg/rg --files for bounded searches; use native PowerShell object APIs,
  LiteralPath and explicit encodings for file operations. Never mix shells for
  recursive moves/deletes. Keep source and destination checks explicit.
- Reuse existing runtimes and libraries. If a new dependency is necessary and the
  task already authorizes it, use an isolated task environment and record it.
  Otherwise explain the concrete need before adding it. No global upgrades.
- Test-framework packages, Semgrep, CodeQL and REA are optional task tools, not
  installation prerequisites for these instruction skills.
