---
name: Palakat
description: The shared operating surface for a church congregation — activities, songs, membership, and the books.
colors:
  primary: "#921573"
  primary-container: "#801265"
  on-primary: "#FFFFFF"
  secondary: "#6B1D84"
  secondary-container: "#DBC9E1"
  on-secondary-container: "#471357"
  tertiary: "#B81D5B"
  success: "#2F7A64"
  warning: "#A56A1F"
  error: "#AD2E4F"
  error-container: "#EBCDD5"
  on-error-container: "#721E34"
  surface: "#F9F9F9"
  surface-container-lowest: "#FFFFFF"
  surface-container-low: "#F3F3F3"
  surface-container: "#EEEEEE"
  surface-container-high: "#E8E8E8"
  surface-container-highest: "#E2E2E2"
  on-surface: "#1A1C1C"
  on-surface-variant: "#474747"
  outline: "#777777"
  outline-variant: "#C6C6C6"
  inverse-surface: "#2F3131"
  inverse-on-surface: "#F1F1F1"
typography:
  display:
    fontFamily: "OpenSans, Roboto, system-ui, sans-serif"
    fontSize: "56sp"
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: "-1.2"
  headline:
    fontFamily: "OpenSans, Roboto, system-ui, sans-serif"
    fontSize: "32sp"
    fontWeight: 600
    lineHeight: 1.12
    letterSpacing: "-0.5"
  title:
    fontFamily: "OpenSans, Roboto, system-ui, sans-serif"
    fontSize: "20sp"
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: "normal"
  body:
    fontFamily: "OpenSans, Roboto, system-ui, sans-serif"
    fontSize: "16sp"
    fontWeight: 400
    lineHeight: 1.55
    letterSpacing: "normal"
  label:
    fontFamily: "OpenSans, Roboto, system-ui, sans-serif"
    fontSize: "14sp"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "0.2"
rounded:
  xs: "4px"
  md: "8px"
  lg: "16px"
  pill: "999px"
spacing:
  compact: "12px"
  block: "16px"
  section: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "16px 18px"
  button-outlined:
    backgroundColor: "{colors.surface-container-lowest}"
    textColor: "{colors.primary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "16px 18px"
  button-text:
    textColor: "{colors.primary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "12px 12px"
  input-field:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "16px 16px"
  card:
    backgroundColor: "{colors.surface-container-lowest}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "16px"
  chip:
    backgroundColor: "{colors.surface-container}"
    textColor: "{colors.on-surface}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  chip-selected:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  list-item:
    backgroundColor: "{colors.surface-container-lowest}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "10px 16px"
  dialog:
    backgroundColor: "{colors.surface-container-lowest}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: "24px"
---

# Design System: Palakat

## 1. Overview

**Creative North Star: "The Quiet Sanctuary"**

A sanctuary is orderly without being cold, and it does not shout to be taken seriously. The room is calm, the light is even, and the few things that carry meaning are placed deliberately. Palakat's interface works the same way: a near-white ground (`#F9F9F9`) holds almost every surface, depth comes from tonal steps rather than shadow, and the magenta accent appears only where a member or operator is meant to act. The code already carries this posture in its own vocabulary: `SanctuaryLayout`, `SanctuaryDepth`, `ghostBorder()`.

The system serves two very different sessions from one visual language. A member opens the app for thirty seconds during service to find a song. A treasurer sits with the admin console for an hour reconciling cash. Neither gets a separate aesthetic. What changes between them is density, not personality: the same 8px corner, the same borderless filled input, the same magenta reserved for intent. Consistency here is a trust argument, because the app that announces Sunday's activity is the same app that reports where the offering went.

This system explicitly rejects the generic SaaS dashboard, with its hero-metric tiles, identical card grids, and gradient accents applied as decoration. It rejects enterprise accounting software, with its grey walls of dense tables and cryptic labels. It rejects the megachurch marketing app, with stock photography and motivational typography standing in for information. And it rejects the consumer social feed, with badge spam and engagement mechanics competing for a member's attention. Every one of those failures is a container or a color used where a decision should have been made.

**Key Characteristics:**
- Near-white ground; a five-step neutral surface ramp does the layering
- Magenta accent (`#921573`) reserved for action and selection, never decoration
- Flat at rest: every theme entry ships `elevation: 0`
- Hairline ghost borders (8–15% opacity) instead of hard rules
- 8px corner everywhere; 16px only for floating surfaces; pills only for chips
- Semantic status colors (success / warning / error) never carry meaning alone

## 2. Colors

A magenta-led palette on a calm neutral ground: the accent is saturated and the room around it is not, so intent reads instantly.

### Primary
- **Sanctuary Magenta** (`#921573`): Primary actions, selected navigation and chips, checkbox and switch fill, focus intent. This is the only color in the system permitted to be loud, and it is permitted only where the user acts.
- **Deep Magenta** (`#801265`): The pressed and container variant. Also carries `surfaceTint` so Material's tonal overlays stay in the family.

### Secondary
- **Vespers Violet** (`#6B1D84`): Supporting emphasis and secondary containers. Sits one hue-step away from primary so the two never compete for the same job.
- **Violet Mist** (`#DBC9E1`): Secondary container fill for tinted informational surfaces.

### Tertiary
- **Rose Signal** (`#B81D5B`): Sparing accent for highlights and unselected switch thumbs. The least-used color in the system by design.

### Neutral
- **Sanctuary Ground** (`#F9F9F9`): The scaffold and app-bar background. Every screen starts here.
- **Paper White** (`#FFFFFF`): Cards, list tiles, dialogs, drawers, popup menus. The one step *above* the ground.
- **Surface Ramp** (`#F3F3F3` → `#EEEEEE` → `#E8E8E8` → `#E2E2E2`): Low / base / high / highest containers. Input fills, inactive chips, and any surface that must recede rather than lift.
- **Ink** (`#1A1C1C`): Body and heading text. Not pure black.
- **Muted Ink** (`#474747`): Secondary text, icons, hints, unselected navigation labels.
- **Outline** (`#777777`) / **Outline Mist** (`#C6C6C6`): Borders and dividers, almost always at reduced opacity via `ghostBorder()`.

### Semantic
- **Ledger Green** (`#2F7A64`): Confirmed, approved, revenue.
- **Pending Amber** (`#A56A1F`): Unconfirmed, awaiting approval, setup incomplete.
- **Ledger Rose** (`#AD2E4F`): Errors, destructive actions, expense.

### Named Rules

**The Reserved Accent Rule.** Sanctuary Magenta covers no more than 10% of any screen. It marks what the user acts on. A heading is not an action. A card border is not an action. A decorative flourish is not an action. If magenta appears anywhere the user cannot tap, remove it.

**The Two-Signal Rule.** Financial and approval state is never carried by color alone. Confirmed, unconfirmed, and pending must each pair their color with a second signal: a label, an icon, or a position in the layout. A treasurer with color-vision deficiency must be able to close the month.

**The No-Gradient Rule.** `AppColors.primaryGradient` exists in the codebase and is legacy. Do not reach for it in new work. Gradients on text are forbidden outright; gradients as surface decoration are forbidden; the accent carries meaning as a flat fill or not at all.

## 3. Typography

**Display / Body / Label Font:** OpenSans (fallback Roboto, then system sans)

**Character:** One humanist sans across the whole system. OpenSans has open apertures and a tall x-height, which is what a mixed-age congregation reading a song lyric in dim light actually needs. A second display face would buy personality and cost legibility; this system does not make that trade. Hierarchy comes from weight and scale, not from font mixing.

> **Implementation gap:** OpenSans is bundled in `apps/palakat/pubspec.yaml` but no `fontFamily` is set in `buildAppTheme()`, so both apps currently render the platform default. This spec declares OpenSans canonical; the missing `fontFamily` is a bug, not a design decision.

### Hierarchy

The scale steps at roughly 1.25× between adjacent roles and tightens letter-spacing as size grows.

- **Display** (700, 56 / 44 / 36 sp, line-height 1.05–1.10, tracking −1.2 to −0.6): Rare. Reserved for a single dominant number or statement on a screen that has nothing else to say.
- **Headline** (600, 32 / 28 / 24 sp, line-height 1.12–1.20, tracking −0.5 to −0.2): Screen titles and section openers. This is the top of the hierarchy on most real screens.
- **Title** (500, 20 / 18 / 16 sp, line-height 1.30–1.34): App-bar titles, card headings, list-item primaries.
- **Body** (400, 16 / 14 / 12 sp, line-height 1.50–1.55): All running text. Cap measure at 65–75 characters; the admin console must not run body text the full width of a desktop viewport.
- **Label** (700, 14 / 12 / 11 sp, tracking 0.2–0.35): Buttons, chips, navigation, form labels, metadata. The weight jump to 700 at small sizes is deliberate and is what separates a label from body text.

### Named Rules

**The Weight-Gap Rule.** Adjacent roles must differ by at least one weight step or 1.25× in size. If a heading and the text under it look like the same thing at arm's length, the hierarchy has failed and no amount of color will fix it.

**The Label-Is-Not-Body Rule.** Label styles are 700 weight with positive tracking. Never use a label style for a sentence, and never set a button in body weight.

## 4. Elevation

Flat by default; depth comes from tone. Every component in `buildAppTheme()` ships `elevation: 0` — cards, dialogs, app bars, buttons, FAB, drawer, popup menus. A surface does not lift, it *changes tone*, stepping along the neutral ramp from Sanctuary Ground up to Paper White or down into the container steps. Where a boundary is genuinely needed, it is drawn as a hairline at low opacity, not as a shadow.

Shadow exists in the system but is ambient, not structural: `SanctuaryDepth.ambient()` renders a single wide, soft, downward shadow at 4–6% opacity with a 40px blur. It reads as light in a room, not as an object floating above a page. `BaseShadow` in the mobile app is a legacy sub-pixel pair (0.36px offsets) and should be considered deprecated.

### Shadow Vocabulary
- **Ambient** (`0 12px 40px rgba(26,28,28,0.05)`): The only sanctioned shadow. Optional atmosphere beneath a major surface. Never a hover affordance, never a card default.
- **Ghost Border** (`1px solid rgba(198,198,198,0.15)`): The default separator, via `AppColors.ghostBorder()`. Dividers drop to 0.08, checkboxes rise to 0.3.

### Named Rules

**The Flat-At-Rest Rule.** Nothing casts a shadow because it exists. If a surface needs to be distinguished, move it one step on the neutral ramp first. Reach for Ambient only when tone alone has failed.

**The 2014 Test.** If a surface looks like a 2014 Material app, the shadow is too dark and the blur is too small. Ambient is 40px of blur at 5%. Anything tighter or darker is wrong.

## 5. Components

Calm and unfussy: an 8px corner, a filled surface, and no chrome that isn't doing work.

### Buttons
- **Shape:** Softly squared corners (8px, `SanctuaryLayout.radius`). Never pills; pills belong to chips.
- **Primary:** Sanctuary Magenta fill, white label, 16px vertical / 18px horizontal padding, Label Large type, zero elevation, transparent shadow.
- **Outlined:** Paper White fill, magenta label, ghost border at 15%. The secondary action, always beside a primary, never alone.
- **Text:** Magenta label on nothing, 12px padding. Tertiary actions and inline navigation only.
- **Hover / Focus:** Splash is `InkSparkle`. Focus must remain visible on keyboard navigation in the admin console; a ripple is not a focus indicator.
- **FAB:** Magenta fill, 16px radius, zero elevation. One per screen or none.

### Chips
- **Style:** Pill (999px), Surface Container fill, Ink label at Label Medium, no border.
- **State:** Selected chips flip to Sanctuary Magenta fill with white label. Selection is a fill change, never a border change.

### Cards / Containers
- **Corner Style:** 8px. Floating surfaces (dialog, popup, FAB) use 16px.
- **Background:** Paper White on the Sanctuary Ground scaffold.
- **Shadow Strategy:** None. Flat at rest, per Elevation.
- **Border:** None by default. A ghost border only when two same-tone surfaces meet.
- **Internal Padding:** 16px (block). Section gaps at 24px, compact groupings at 12px.
- **Restraint:** A card must earn itself. If spacing and type can express the grouping, use spacing and type. Nested cards are forbidden.

### Inputs / Fields
- **Style:** Borderless and filled. Surface Container fill, 8px radius, `isDense`, 16px padding all round. No enabled or focused border at all.
- **Focus:** Currently expressed by fill and cursor only. This is the system's weakest point for keyboard and low-vision users; new work should add a visible focus treatment rather than inherit the borderless default.
- **Error:** A 1px error-colored border at 30% opacity. Pair with an error message; the border alone is below the Two-Signal Rule.
- **Hint:** Muted Ink at 72% opacity, Body Medium.

### Navigation
- **Mobile bottom bar:** Sanctuary Ground at 92% opacity, zero elevation. Selected items in magenta, unselected in Muted Ink, both at Label Small. Destinations are always visible and always labelled; no hidden overlay menus, no gesture-only access to work areas.
- **Admin sidebar:** 288px fixed (`desktopSidebarWidth`). Content caps at 1440px desktop, 840px mobile.
- **Horizontal padding scale:** 16px under 600px, 24px under 960px, 32px to 1600px, 40px beyond.

### List Items
The workhorse of this system and the preferred alternative to a card grid. Paper White tile, 8px radius, 16px horizontal / 10px vertical padding, Muted Ink icons. A list of list-items separated by ghost dividers is almost always better than the same content in cards.

## 6. Do's and Don'ts

### Do:
- **Do** start every screen on Sanctuary Ground (`#F9F9F9`) and step up to Paper White (`#FFFFFF`) only for content surfaces that need separation.
- **Do** keep Sanctuary Magenta (`#921573`) under 10% of the screen and only on things the user can act on.
- **Do** express grouping with the 12 / 16 / 24px spacing scale and type weight before reaching for a container.
- **Do** pair every financial and approval state with a second non-color signal: label, icon, or position.
- **Do** use list items with ghost dividers where a card grid is the reflex.
- **Do** hold the 8px corner. 16px is for floating surfaces only; 999px is for chips only.
- **Do** cap body measure at 65–75 characters, especially in the admin console.
- **Do** let longer Indonesian labels wrap rather than truncate.
- **Do** honor reduced-motion preferences; motion in this system is state feedback, never choreography.

### Don't:
- **Don't** build a **generic SaaS dashboard**: no hero-metric tiles, no identical card grids, no gradient accents, no decorative chrome around content that could stand alone.
- **Don't** build **enterprise accounting software**: no grey walls of dense tables, no cryptic column labels, no screens that expose raw database shape.
- **Don't** build a **megachurch marketing app**: no stock photography, no hero video, no motivational typography where informational design is needed.
- **Don't** build a **consumer social feed**: no infinite scroll, no engagement mechanics, no badge spam, no notification noise competing with content.
- **Don't** use `background-clip: text` with a gradient, or reach for `AppColors.primaryGradient` in new work.
- **Don't** use a colored `border-left` or `border-right` above 1px as a stripe on cards, list items, callouts, or alerts. Use a full ghost border, a tonal fill, or nothing.
- **Don't** nest a card inside a card. Ever.
- **Don't** add a shadow to indicate hover. Change tone.
- **Don't** hide operator features behind unusual interaction patterns; work destinations are standard, labelled, and visible.
- **Don't** introduce a second typeface. One humanist sans, five roles, weight and scale do the rest.
- **Don't** let a warning banner, setup prompt, or system notice sit above the screen's dominant content.
- **Don't** reach for a modal first. Exhaust inline and progressive alternatives.
