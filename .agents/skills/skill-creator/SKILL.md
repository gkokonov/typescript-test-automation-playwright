---
name: skill-creator
description: Create or update project skills and validate their instructions, references and behavior.
---

# Skill Creator

## Critical

- Keep skills focused, actionable and independent of a particular agent host.
- Preserve existing project conventions and authoritative instructions.
- Validate links, routing and examples after changes.

## Procedure

1. Identify the requested behavior, scope and existing related skills.
2. Update the relevant skill and references with concise instructions.
3. Run `npm run check:skills` and relevant behavioral checks; report their results.

## References

- Project conventions: `AGENTS.md`.
