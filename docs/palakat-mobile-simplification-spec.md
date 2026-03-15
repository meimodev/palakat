# Palakat Mobile Simplification Spec

## Goal

Simplify the Palakat mobile app so the interface feels clear and member-friendly without removing operator capabilities.

## Primary Product Decision

- General members come first in the mobile shell.
- Church work actions remain available, but they should no longer dominate or hide the main browsing flow.

## Core User Priorities

### General members

- See what is happening this week.
- Open songs quickly.
- Read articles.
- Manage account and membership.

### Church operators

- Reach approvals quickly.
- Access operations and publishing tools.
- Generate reports and complete work tasks with minimal friction.

## Simplification Principles

- One screen should have one dominant purpose.
- Primary browsing actions should be visible at the shell level.
- Church work features should be explicit, not hidden behind unusual interaction patterns.
- Secondary states such as warnings, setup prompts, and system notices should not crowd the main content.
- Use progressive disclosure for advanced options and filters.
- Prefer fewer visible containers and less repeated card chrome where hierarchy can be expressed with spacing and typography.

## Mobile IA Direction

### Shell priority

Top-level navigation should prioritize member tasks in this order:

1. Home
2. Songs
3. Articles
4. Church / Operations
5. Approvals

### Shell rules

- Remove the hidden church overlay menu from the bottom navigation.
- Make work areas directly reachable as standard destinations.
- Keep protected tabs gated by authentication and membership state.
- Preserve current feature access; this is a hierarchy change, not a permission change.

## Screen-Level Direction

### Dashboard

Current issue:
- Too many banners, notices, status cards, and utility actions compete with the weekly overview.

Direction:
- Make the weekly overview the dominant content.
- Keep account and membership summary lightweight.
- Reduce visual interruption from permission and system notices.
- Move secondary notices lower or collapse them behind a clearer entry point.

### Song Book

Current issue:
- Useful flow, but metadata and update surfaces compete with the main browse/search action.

Direction:
- Keep search and open-song flow primary.
- Reduce pre-content chrome before the search field and content list.
- Keep update/download messaging visible only when needed.

### Operations

Current issue:
- Too many categories and supporting sections appear at once.

Direction:
- Make recent or high-value tasks easier to scan first.
- Keep category expansion, but reduce upfront visual density.
- Treat reports and secondary supporting data as subordinate to task entry points.

### Approvals

Current issue:
- Functional, but filter controls and grouped sections create a dense first impression.

Direction:
- Prioritize “needs my action” above all else.
- Reduce the amount of filtering UI visible before the list.
- Keep historical states accessible but visually secondary.

### Reports / task-heavy forms

Current issue:
- Too many options appear at once for a small mobile screen.

Direction:
- Show only fields required for the selected report type.
- Lean on smart defaults more aggressively.
- Group advanced filters after primary inputs.
- Keep the primary action persistent and obvious.

## Visual Direction

- Maintain the current design system foundation.
- Reduce unnecessary elevation, borders, and stacked card treatments where possible.
- Use spacing and typography to create hierarchy before adding more containers.
- Preserve accessibility, touch target clarity, and localization support.

## Implementation Order

1. Simplify shell and navigation.
2. Rebalance dashboard hierarchy.
3. Simplify operations and approvals entry flows.
4. Simplify report generation.
5. Polish Song Book chrome.

## Success Criteria

- Member-first tasks are immediately discoverable.
- Church work areas are explicit and easier to reach.
- The app no longer depends on hidden navigation patterns.
- The dashboard feels lighter and easier to scan.
- Task-heavy flows expose less complexity up front.
