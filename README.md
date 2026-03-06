# agentSDLC

agentSDLC is a practical operating model for building software with AI agents and Claude Code.

It reframes the traditional SDLC around small, deployable, end-to-end slices of work that can be reasoned about, implemented, tested, and verified within a single Claude Code working context.

The goal is not just to make software delivery faster.

The goal is to make it more reliable, more reviewable, and more evidence-led.

## Why this repo exists

Traditional software delivery often breaks work into disconnected layers:

- requirements first
- then design
- then frontend
- then backend
- then testing
- then deployment

That creates handoffs, delayed feedback, hidden dependencies, and fake progress.

agentSDLC replaces that with a vertical-slice model.

Each slice should aim to create clear value for a named recipient, include all necessary full-stack work for that outcome, and leave the system in a deployable state.

## Core delivery doctrine

We deliver software as small, deployable, end-to-end vertical slices.

A valid slice must:

- create clear value for an identified recipient
- include all required work across the stack for that outcome
- stay within acceptable context window usage
- include tests and proof that it works
- leave the system in a deployable state

Value may be for the user, the business, or the product team.

If context window usage is too high, the slice must be split.

## What “context window usage” means

Context window usage is a sizing signal for agent-delivered work.

It describes how much working memory, codebase context, architectural awareness, and task history Claude Code must hold to complete a slice coherently.

Levels:

- **Low**: small, cohesive, easy to hold in one working context
- **Medium**: still feasible in one task, but needs a tightly scoped brief
- **High**: likely to strain one Claude Code task and should trigger a split review

High context window usage does not automatically make a slice invalid, but it should be treated as a warning.

## Value model

Every slice should identify:

- **Value recipient**: who benefits
  - User
  - Business
  - Product team
  - Developer team
  - Operations / support

- **Value type**: what kind of value it creates
  - Delivering
  - Enabling
  - Improving

- **Value visibility**: how visible the value is after deployment
  - Directly visible
  - Indirectly visible
  - Internal only

This stops the system from rejecting valid enabling work while still forcing clarity about why a slice exists.

## Initial skill chain

This repo starts with the first skill in the chain:

1. `idea-to-prd`

Planned follow-on skills:

1. `idea-to-prd`
2. `prd-to-vertical-slices`
3. `slice-to-build-brief`
4. `slice-test-and-proof`
5. `release-readiness-check`

## Repository layout

- `docs/`
  - core doctrine, definitions, and registry documents
- `.claude/skills/`
  - project-local Claude Code skills
- each skill folder contains:
  - `SKILL.md`
  - optional templates
  - optional examples
  - optional references
  - optional scripts

## How to use this repo

### In Claude Code

Place this repository in your project and ensure Claude Code has access to the repo.

Project skills should live at:

`.claude/skills/<skill-name>/SKILL.md`

Claude Code can discover and use these skills when relevant.

### Working style

The intended working loop is:

1. capture raw idea material
2. run `idea-to-prd`
3. review and approve the PRD
4. convert approved PRD into slices
5. turn a slice into a build brief
6. implement, test, prove, and release

## Design principles for skills in this repo

Every skill should declare:

- inputs required
- outputs produced
- companion skills
- tooling or scripts used
- MCPs and fallback behaviour

Skills should be small, focused, and composable.

Avoid giant orchestration prompts.

## Current status

This starter version includes:

- repo doctrine
- slice and delivery principles
- skill registry
- first full skill: `idea-to-prd`

## Future direction

The repo will gradually become a practical agent operating system for software delivery:

- discovery
- requirements shaping
- vertical slicing
- implementation planning
- testing and proof
- release readiness

The aim is not abstraction for its own sake.

The aim is to make AI-assisted delivery structured enough to trust.

## Install globally into Claude Code

This installs agentSDLC skills into your global Claude Code skills directory:

`~/.claude/skills`

It does not remove or overwrite unrelated existing Claude setup.

### Install all skills

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- install --all

```

### Install one skill

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- install --skill idea-to-prd

```

### Update all managed skills

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- update --all

```

### List installed skills

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- list

```

### Run doctor

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- doctor

```

### Uninstall one managed skill

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- uninstall --skill idea-to-prd

```

### Uninstall all managed skills

```
curl -fsSL https://raw.githubusercontent.com/famerazak/agentSDLC/main/scripts/agentsdlc-installer.sh | bash -s -- uninstall --all

```