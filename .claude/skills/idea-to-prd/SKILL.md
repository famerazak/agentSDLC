---
name: idea-to-prd
description: Convert raw product ideas, meeting notes, brainstorms, or transcripts into a structured PRD. Use after discovery or ideation when messy input needs to become a reviewable product requirements document.
---

# idea-to-prd

## Purpose

Turn messy input into a clear PRD that can be reviewed by humans and then used by downstream skills.

This skill is for the stage where someone has explained an idea out loud, captured rough notes, dumped thoughts into chat, or shared a loose set of requirements, but there is not yet a disciplined product document.

The output should reduce ambiguity without pretending certainty where none exists.

## What good looks like

A strong PRD created by this skill should:

- describe the problem clearly
- define the intended outcome
- identify who the product or feature is for
- separate requirements from assumptions
- identify scope boundaries
- list open questions
- be clear enough that downstream slicing can begin

## Inputs required

Use this skill when you have one or more of:

- brainstorm notes
- meeting transcript
- voice transcript
- rough bullet list
- chat log
- stakeholder summary
- pasted product idea dump

If multiple inputs are provided, combine them into one coherent view and resolve contradictions explicitly rather than silently.

## Outputs produced

Produce:

1. a structured PRD in Markdown
2. assumptions
3. constraints
4. open questions
5. scope notes
6. success criteria

If asked to save output to a file, write the PRD using the template in `templates/PRD_TEMPLATE.md`.

## Companion skills

Likely upstream:
- none

Likely downstream:
- `prd-to-vertical-slices`

Do not try to perform downstream slicing inside this skill unless the user explicitly asks for it.

## Built-in capabilities to use

Use Claude Code capabilities such as:

- reading source files and notes
- comparing multiple documents
- drafting structured Markdown
- extracting themes and requirements
- identifying contradictions and gaps

## External context / MCPs

Optional context sources may improve the result:

- Notion or docs systems for existing notes
- meeting transcript systems
- GitHub or repo context for current product constraints
- web research for domain understanding or competitor references
- issue tracker context for existing scope

Do not fail if these are unavailable.

## Fallback behaviour

If no external systems are available, work only from the supplied material and explicitly state:

- what was provided
- what was inferred
- what remains unknown

## Working rules

1. Do not over-invent.
2. Do not turn guesses into facts.
3. If the source material is vague, preserve that vagueness as an open question.
4. Prefer clarity over polish.
5. Separate business intent from implementation detail.
6. Avoid jumping into architecture unless it is explicitly necessary to explain a requirement.
7. Where appropriate, highlight conflicts or ambiguity rather than smoothing them away.

## Required process

Follow this process in order.

### Step 1: Ingest the source material

Read all supplied inputs carefully.

Create a quick internal map of:

- product or feature idea
- problem being discussed
- intended users or stakeholders
- outcomes people care about
- constraints or concerns
- anything that sounds unresolved

If there are multiple sources, reconcile them carefully and record any contradictions.

### Step 2: Identify the problem

Extract the actual problem being solved.

Write it in plain English.

Do not write a solution-first PRD if the problem is still unclear.

If the source material contains only solutions, infer the likely problem and mark it as inferred.

### Step 3: Identify the target actors

List the main actors involved, for example:

- end users
- admins
- operators
- business stakeholders
- internal product team

Keep this practical.

Do not invent personas with marketing fluff unless the source material supports them.

### Step 4: Extract goals and success criteria

Identify the intended goals.

Then define how success would be judged.

Use measurable success criteria where possible.
If precise metrics are not known, write qualitative success criteria and mark missing metrics as open questions.

### Step 5: Extract requirements

Break requirements into:

- functional requirements
- non-functional requirements

Functional requirements describe what the system should do.

Non-functional requirements describe qualities or constraints such as:

- performance
- reliability
- security
- compliance
- permissions
- usability
- observability
- auditability

Do not bury non-functional requirements inside prose.

### Step 6: Identify constraints and assumptions

Separate:
- known constraints
from
- inferred assumptions

Examples of constraints:
- must use current stack
- must work on mobile
- must support existing auth
- must launch this quarter

Examples of assumptions:
- users will already be logged in
- existing data model can support this
- admin role already exists

Be explicit.

### Step 7: Define scope boundaries

Create sections for:

- in scope
- out of scope
- future considerations

This is important.

If the source material is broad, narrow the PRD to a coherent scope and record any leftovers under future considerations.

### Step 8: Surface unknowns

Create an `Open Questions` section.

Questions should be practical and decision-relevant.

Good examples:
- Which user roles can perform this action?
- Does this require audit history?
- Is this mobile-only, desktop-only, or both?
- What is the source of truth for this data?
- Does this need to be feature-flagged?

### Step 9: Draft the PRD

Use the template in `templates/PRD_TEMPLATE.md`.

If that file is unavailable, use the exact structure defined below.

## Output structure

Use this structure exactly unless the user asks for a different format.

# [Working title]

## 1. Summary
A short description of the feature or product idea.

## 2. Problem Statement
What problem is being solved and why it matters.

## 3. Users and Stakeholders
Who this is for and who cares about the outcome.

## 4. Goals
The intended outcomes.

## 5. Success Criteria
How success will be judged.

## 6. Functional Requirements
A numbered list.

## 7. Non-Functional Requirements
A numbered list.

## 8. Constraints
Known limits or hard boundaries.

## 9. Assumptions
Inferred statements that need confirmation.

## 10. In Scope
What this PRD covers.

## 11. Out of Scope
What this PRD does not cover.

## 12. Future Considerations
Related work that may come later.

## 13. Open Questions
Outstanding questions that affect delivery quality or correctness.

## 14. Notes from Source Material
Important source details worth preserving.

## Writing guidance

### Style
- write clearly and plainly
- avoid consultancy filler
- avoid hype
- avoid pretending vague ideas are precise
- avoid architecture deep-dives unless necessary

### Precision
- use numbered requirements where possible
- state unknowns directly
- prefer concrete wording over abstract wording

### Behaviour
- if the user's source material is chaotic, impose order
- if the source material is contradictory, expose the contradiction
- if the source material is thin, produce a lean PRD and expand the `Open Questions` section

## Value-awareness note

This skill should not yet force value recipient tagging per slice.

That happens later during slicing.

At PRD stage, it is enough to identify:

- who the product or feature is for
- who cares about the outcome
- what problem or opportunity exists

## Save behaviour

If the user asks for a file, write the PRD to a Markdown file.

Default filename:

`prd.md`

If the user provides a working title, use a slugged filename based on it.

## Example prompts this skill should handle well

- "Turn these meeting notes into a PRD"
- "I just dumped my product idea into this file. Create a PRD"
- "Here’s a transcript from a call with a founder. Pull out the real requirements"
- "Take this rough feature idea and give me a clean PRD with open questions"

## References

See:
- `templates/PRD_TEMPLATE.md` for the output structure
- `examples/input-idea.md` for sample messy source material
- `examples/output-prd.md` for a sample result
- `references/interviewing-notes.md` for practical guidance when extracting intent from conversation-heavy input