# Slice Definition

## Vertical slice definition

A vertical slice is the smallest deployable unit of work that:

1. creates clear value for a named recipient
2. includes all required changes across the stack for that outcome
3. can be implemented, tested, and verified within acceptable context window usage
4. leaves the system in a deployable state

## Required slice fields

Every slice should define:

- Slice name
- Outcome
- Value recipient
- Value type
- Value visibility
- Why this matters
- Entry point / touchpoint
- UI changes
- Backend / service changes
- API changes
- Database changes
- Permissions / auth impact
- Telemetry / logging needs
- Tests required
- Proof required
- Deployment notes
- Context window usage
- Split recommendation if needed
- Dependencies
- Out of scope

## Context window usage

### Low
Small and cohesive. Claude Code should be able to reason about the task comfortably in one working context.

### Medium
Still feasible in one task, but the brief must be tight and the implementation path should stay controlled.

### High
Likely to strain one working context. Usually needs to be split.

## Split rule

If a proposed slice cannot reasonably be understood, implemented, tested, and verified inside one Claude Code working context, it should be split into smaller slices.

## Proof of completion

A slice should define what counts as evidence.

Examples:

- test output
- screenshot or screen recording
- API request and response examples
- schema migration evidence
- deployed environment check
- short manual verification notes

## Example

### Slice name
Show subscription status badge on account page

### Outcome
A logged-in user can see their current subscription status from the account page.

### Value recipient
User, Business

### Value type
Delivering

### Value visibility
Directly visible

### Context window usage
Low

### Why this matters
Users understand their current access state and support confusion is reduced.

### UI changes
Add badge to account summary card.

### Backend / service changes
Expose current subscription state in account service.

### API changes
Add subscription status field to account response.

### Database changes
None.

### Tests required
Unit test for response mapping, integration test for account response, UI render test.

### Proof required
Screenshot of badge state, API response example, test output.

This is a valid slice because it is small, deployable, valuable, and coherent.