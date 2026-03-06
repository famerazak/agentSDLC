---
name: prd-to-vertical-slices
description: Convert a PRD into small deployable vertical slices suitable for AI-driven implementation.
---

# prd-to-vertical-slices

## Purpose

Transform a Product Requirements Document (PRD) into a set of small, deployable vertical slices.

Each slice should:

- create clear value
- include full-stack work where required
- be deployable
- include tests
- include proof
- remain small enough for a single Claude Code working context

The goal is to prevent oversized implementation tasks.

---

# Inputs

Required:

- a PRD document

Optional context:

- existing codebase
- architecture notes
- UI designs
- API specifications

---

# Output

Produce a structured list of slices.

Each slice must include:

- Slice name
- Outcome
- Value recipient
- Value type
- Value visibility
- Why it matters
- Entry point
- UI changes
- Backend changes
- API changes
- Database changes
- Permissions impact
- Tests required
- Proof required
- Deployment notes
- Context window usage
- Dependencies
- Out of scope

---

# Slice rules

Slices must follow these rules.

## Rule 1 — slices must create value

Each slice must state who benefits.

Value recipient options:

- User
- Business
- Product team
- Developer team
- Operations / support

---

## Rule 2 — classify value type

Each slice must classify the value it creates.

Value type:

- Delivering
- Enabling
- Improving

---

## Rule 3 — classify visibility

Value visibility:

- Directly visible
- Indirectly visible
- Internal only

---

## Rule 4 — slices should be deployable

A slice should leave the system in a working state.

---

## Rule 5 — slices must include tests

Every slice must include testing requirements.

---

## Rule 6 — slices must include proof

Examples of proof:

- screenshots
- test results
- API responses
- logs
- database records

---

## Rule 7 — respect context window usage

Estimate context window usage.

Levels:

Low  
Medium  
High

If High, recommend splitting the slice.

---

# Slice sizing guidance

Good slice examples:

- show subscription badge
- save onboarding answer
- send first reminder email
- display analytics summary card

Bad slice examples:

- build onboarding
- implement authentication
- create dashboard system
- add notification infrastructure

---

# Required process

Follow this order.

## Step 1 — read the PRD

Understand:

- goals
- actors
- requirements
- constraints

---

## Step 2 — identify product surfaces

Identify user or system surfaces such as:

- pages
- dashboards
- APIs
- workflows
- integrations

---

## Step 3 — derive thin vertical slices

Break work into outcomes that:

- are deployable
- produce value
- remain small

---

## Step 4 — tag value and visibility

Add:

- value recipient
- value type
- value visibility

---

## Step 5 — estimate context window usage

Assess whether the slice can be implemented in a single Claude Code task.

---

## Step 6 — identify dependencies

Note any slices that must be completed first.

---

# Output

1. Generate the vertical slice plan.
2. Save the result as a Markdown file.
3. Confirm the saved file location.

Example confirmation:

Saved slice plan to:

vertical-slices.md

---

# Example slice

## Slice 1 — Display onboarding step

Value recipient: User  
Value type: Delivering  
Value visibility: Directly visible  
Context window usage: Low  

Outcome:
User sees the first onboarding question.

Why this matters:
Users understand how to begin setup.

Entry point:
Onboarding screen.

UI changes:
Add question component.

Backend changes:
None.

API changes:
None.

Database changes:
None.

Permissions impact:
Authenticated users only.

Tests required:
UI render test.

Proof required:
Screenshot + test output.

Deployment notes:
Feature flag optional.

Dependencies:
None.

Out of scope:
Saving answers.

# Behaviour rules

## Do not:

- invent unnecessary architecture
- create large slices
- ignore testing

## Prefer:

- thin increments
- full-stack thinking
- clear outcomes

# Companion skills

## Upstream:

idea-to-prd

## Downstream:

slice-to-build-brief

# Goal

Turn vague scope into a delivery-ready slice plan.

## Save behaviour

The generated slice plan must be saved to a new Markdown file.

Never overwrite the input PRD.

Default filename:
vertical-slices.md

If the input file is named something specific, use a related filename.

Examples:

prd.md → vertical-slices.md  
booking-prd.md → booking-vertical-slices.md  
caly-prd.md → caly-vertical-slices.md

If a file already exists, append a version:

vertical-slices-v2.md
vertical-slices-v3.md

After generating the slice plan, write the file to disk and confirm the file path.

Save the file in:
docs/slices/

If the directory does not exist, create it.

So your project ends up like:

project
│
├─ prd.md
│
├─ docs
│   └─ slices
│        └─ vertical-slices.md

## Recommended naming convention

Use this pattern:
docs/slices/<product>-vertical-slices.md

Example:

docs/slices/caly-vertical-slices.md
docs/slices/reframe-vertical-slices.md
docs/slices/crm-vertical-slices.md


