# Attribution and local changes

Upstream: [morluto/rea](https://github.com/morluto/rea), published `rea-agents@6.5.0` skill (metadata version 42). The original license and attribution are retained in [LICENSE](LICENSE).

MN-Tech engineering R03 portable, 2026-10-17:

- Extends the description and adds project routing, existing-authorization reuse, evidence and installation boundaries.
- Makes delegation conditional on current project and user instructions.
- Retains all six upstream reference documents without edits, including the 6.5.0 connection/recovery guide.
- Carries forward the generic local engineering rules and agent metadata from R02.
- Adds the scoped Windows compatibility reference and separate installation/validation documentation.
- Documents the expected canonical-skill `stale` diagnostic and the `--skill=false` registration-repair scope that preserves this customization.

Upstream examples remain examples, not permission to run their side effects. The runtime itself is not patched or bundled. This adaptation is maintained by the fork owner and is not an upstream certification.
