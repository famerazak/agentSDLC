# Skill Registry

This document describes the intended skill chain, dependency relationships, expected inputs and outputs, and external context dependencies.

## Registry fields

Each skill entry includes:

- purpose
- inputs required
- outputs produced
- companion skills
- built-in tools
- optional MCPs
- required MCPs
- fallback behaviour

---

## Skill: `idea-to-prd`

### Purpose
Convert raw idea material into a structured PRD suitable for review and downstream slicing.

### Inputs required
- transcript
- notes
- brainstorm dump
- meeting summary
- voice transcript
- rough bullet list

### Outputs produced
- product requirements document in Markdown
- assumptions
- open questions
- scope notes
- success criteria
- requirement list

### Companion skills
- none required upstream
- likely followed by `prd-to-vertical-slices`

### Built-in tools
- read files
- write files
- summarise content
- structure Markdown
- optionally compare multiple input sources

### Optional MCPs
- Notion
- Google Docs
- meeting transcript tools
- GitHub repo context
- web research for domain context or competitor checks

### Required MCPs
- none

### Fallback behaviour
If no MCPs are available, operate on the supplied notes/transcript only and clearly state any missing context.

---

## Skill: `prd-to-vertical-slices`

### Purpose
Turn an approved PRD into small, deployable, end-to-end vertical slices.

### Inputs required
- approved PRD
- product constraints if available
- existing codebase context if available

### Outputs produced
- slice list
- value tags
- context window usage tags
- dependencies
- split recommendations

### Companion skills
- `idea-to-prd` upstream
- likely followed by `slice-to-build-brief`

### Built-in tools
- read files
- search repo
- write structured Markdown
- compare scope items

### Optional MCPs
- GitHub
- Linear / issue tracker
- Figma
- Notion
- architecture docs source

### Required MCPs
- none initially

### Fallback behaviour
If external sources are unavailable, slice from the PRD only and mark any structural assumptions.

---

## Skill: `slice-to-build-brief`

### Purpose
Turn one approved slice into an implementation-ready full-stack build brief.

### Inputs required
- approved slice
- existing repo context
- architecture or code conventions if available

### Outputs produced
- implementation brief
- files likely affected
- API and data contract notes
- test plan
- proof checklist
- deployment considerations

### Companion skills
- `prd-to-vertical-slices` upstream
- likely followed by `slice-test-and-proof`

### Built-in tools
- repo search
- file reading
- file writing
- optionally validation scripts

### Optional MCPs
- GitHub
- Figma
- database schema source
- issue tracker
- internal docs source

### Required MCPs
- none initially

### Fallback behaviour
If external systems are unavailable, derive the build brief from the approved slice and local repo context only.

---

## Skill: `slice-test-and-proof`

### Purpose
Define and collect the evidence needed to prove a slice works across the stack.

### Inputs required
- build brief
- implemented code
- test output if available
- deployment target information if available

### Outputs produced
- proof pack
- test coverage summary
- verification checklist
- evidence summary
- gaps or failures

### Companion skills
- `slice-to-build-brief` upstream
- likely followed by `release-readiness-check`

### Built-in tools
- read changed files
- inspect tests
- generate proof summary
- write Markdown

### Optional MCPs
- GitHub
- CI provider
- deployment platform
- logs / observability systems

### Required MCPs
- none initially

### Fallback behaviour
If external runtime evidence is unavailable, produce the best possible local proof summary and clearly call out missing evidence.

---

## Skill: `release-readiness-check`

### Purpose
Assess whether a completed slice is ready to release.

### Inputs required
- slice proof pack
- test results
- deployment evidence
- unresolved risks

### Outputs produced
- release recommendation
- hold reasons
- risk summary
- follow-up actions

### Companion skills
- `slice-test-and-proof` upstream

### Built-in tools
- compare checklists
- read proof artefacts
- summarise risk

### Optional MCPs
- CI/CD
- observability
- deployment environment
- issue tracker

### Required MCPs
- none initially

### Fallback behaviour
If live environment context is missing, provide a conditional release recommendation and explicitly note what could not be verified.

---

## Dependency philosophy

Skills in this repo are intentionally small and composable.

They should not be treated as one giant hard-wired chain.

Each skill should:
- declare what it expects
- declare what it produces
- declare which skill is likely next
- degrade gracefully if optional external context is unavailable