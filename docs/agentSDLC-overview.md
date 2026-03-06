# agentSDLC Overview

agentSDLC is a reworked software delivery lifecycle designed for AI-assisted product development.

Traditional SDLC models are useful for understanding the stages of delivery, but they often assume phase-based handoffs and human coordination overhead across separate teams. In practice, AI collapses many of those delays.

The biggest change is not that every stage disappears.

The biggest change is that thinking, documentation, implementation, testing, and validation can happen in much tighter loops.

## Traditional lifecycle thinking

A typical SDLC includes:

- planning
- requirements analysis
- design
- development
- testing
- deployment
- maintenance

These stages are still real.

What changes is how separated they need to be.

## agentSDLC thinking

agentSDLC keeps the discipline of delivery but changes the unit of work.

Instead of treating work as large documents, layer-specific tickets, or long handoffs, it treats delivery as a series of small, evidence-backed vertical slices.

Each slice should:

- create clear value
- include all required full-stack work
- remain small enough for a single Claude Code working context
- include tests
- include proof
- leave the product in a deployable state

## Why this matters

Without this approach, AI coding tends to create:

- broad vague tasks
- accidental architecture
- incomplete features
- poor testing discipline
- false confidence from code that “looks done”

agentSDLC is designed to reduce those risks.

## Core concepts

### 1. Vertical slices
Work is organised as small outcomes, not technical layers.

### 2. Value recipients
A slice may create value for:
- the user
- the business
- the product team
- the developer team
- operations / support

### 3. Context window usage
A slice must be scoped so Claude Code can complete it coherently in one task.

### 4. Proof of completion
A slice is not done just because code exists.
It needs evidence.

### 5. Composable skills
The workflow is implemented through small Claude Code skills, not one giant prompt.

## Skill flow

Planned flow:

1. `idea-to-prd`
2. `prd-to-vertical-slices`
3. `slice-to-build-brief`
4. `slice-test-and-proof`
5. `release-readiness-check`

## What this repo is for

This repo is not just documentation.

It is the beginning of an executable working system for AI-assisted product delivery using Claude Code skills.