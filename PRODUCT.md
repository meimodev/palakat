# Product

## Register

product

## Users

Four groups share one platform, split across a Flutter mobile app and two web consoles.

**General members** (primary, mobile). Congregation members on phones, mixed ages and varied tech literacy. They open the app briefly and with a specific intent: see what is happening this week, open a song during service, read an article, manage their own account and membership. Often used in a church building, sometimes in low light, often one-handed while something else is happening.

**Church operators** (mobile + admin web). Volunteers and staff who publish activities, handle approvals, and complete work tasks between other responsibilities. They are not full-time software users; every extra step costs them.

**Church treasurers and finance** (admin web). Heavy users of cash, expense, revenue, approval rules, and reports. They work in longer sessions and need accuracy over speed.

**Super admins** (super admin web). Platform operators managing multiple churches.

The mobile shell belongs to members first. Operator capability stays fully reachable, but never dominates member browsing.

## Product Purpose

Palakat is the shared operating surface for a church congregation: activity announcements and reminders, the song book, articles, membership records, and the church's financial books with an approval trail.

It exists so a congregation does not run on group chats, printed bulletins, and a spreadsheet only one person understands. Success is a member who checks the app instead of asking someone, an operator who publishes an activity without help, and a treasurer whose month closes without reconstruction.

## Brand Personality

Warm, orderly, trustworthy.

Welcoming to a member who opens it twice a week. Disciplined enough to be believed when it reports money. Voice is plain and direct, in the congregation's own language, never corporate and never preachy. Labels name the real thing ("Approvals", "Cash", "This week"), not abstractions.

## Anti-references

- **Generic SaaS dashboard.** Hero-metric tiles, identical card grids, gradient accents, decorative chrome around content that could stand alone.
- **Enterprise accounting software.** Grey walls of dense tables, cryptic column labels, no visual hierarchy, features exposed as raw database shape.
- **Megachurch marketing app.** Stock photography, hero video, motivational typography, emotional design where informational design is needed.
- **Consumer social feed.** Infinite scroll, engagement mechanics, badge spam, notification noise competing for attention.

## Design Principles

1. **One screen, one dominant purpose.** Everything else on the screen is subordinate to it, visually and spatially. Secondary states (warnings, setup prompts, system notices) never crowd the main content.

2. **Hierarchy from spacing and typography, not containers.** Fewer visible boxes. Card chrome must earn itself; repeated card grids are a failure to decide what matters.

3. **Members first, operators reachable.** Work features are explicit standard destinations, never hidden behind unusual interaction patterns, and never in front of member browsing.

4. **Progressive disclosure for depth.** Advanced options, filters, and finance detail exist behind a deliberate step. The default view is the common case.

5. **Money is legible.** Financial states (confirmed, unconfirmed, pending approval) are distinguishable at a glance without reading numbers. Ambiguity here is a trust failure, not a polish issue.

## Accessibility & Inclusion

WCAG 2.1 AA.

- 4.5:1 contrast on body text, 3:1 on large text and meaningful UI boundaries.
- Tap targets sized for real-world one-handed phone use.
- State never carried by color alone; finance and approval status need a second signal (label, icon, position).
- Respect reduced-motion preferences.
- Indonesian is the primary interface language; layouts must tolerate longer label strings without truncation.
