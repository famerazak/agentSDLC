# Delivery Principles

These principles govern how work should be shaped and executed in agentSDLC.

## 1. Deliver small, complete outcomes

Prefer small, end-to-end increments over broad partial progress.

Bad:
- build all onboarding backend
- create dashboard infrastructure
- refactor payment services

Better:
- show onboarding progress step on the dashboard
- allow the user to save one onboarding answer
- display current subscription status badge

## 2. Avoid layer-only delivery

A task should not be considered complete just because one layer is done.

If the feature outcome requires UI, service logic, API work, schema changes, tests, and deployment checks, the slice should include them.

## 3. Name the value recipient

Every slice must identify who benefits:

- User
- Business
- Product team
- Developer team
- Operations / support

If you cannot say who benefits, the slice is probably not well formed.

## 4. Name the value type

Every slice must classify the kind of value it creates:

- Delivering
- Enabling
- Improving

This helps distinguish real enabling work from vague technical motion.

## 5. Be explicit about value visibility

Every slice should state whether the result is:

- Directly visible
- Indirectly visible
- Internal only

This prevents the system from assuming only UI-visible work is valuable.

## 6. Respect context window usage

A slice should be small enough for one Claude Code task to hold coherently.

Levels:

- Low
- Medium
- High

If usage is High, trigger a split review.

## 7. Require proof, not just output

A slice is not done because code compiles or the UI looks plausible.

Done means there is evidence.

## 8. Keep the product deployable

A valid slice should leave the system in a deployable state, even if it is guarded, partial, internal, or low-visibility.

## 9. Prefer thin, working increments

Thin, complete slices beat thick, ambiguous tasks.

## 10. Make ambiguity visible

If something is not known, record it as:
- assumption
- dependency
- open question
- risk

Do not hide uncertainty inside implementation.