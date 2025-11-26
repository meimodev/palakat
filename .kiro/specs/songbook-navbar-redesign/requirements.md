# Requirements Document

## Introduction

This specification defines the design rehaul for the Palakat mobile app's Song Book screen and Bottom Navigation Bar, applying the same design principles established in the Operations screen redesign. The goal is to create a visually cohesive, calm, and user-friendly experience that aligns with the monochromatic teal color system and progressive disclosure patterns already implemented in the app.

The redesign focuses on:
1. **Song Book Screen Redesign**: Transform the current song book screen to use category-based organization with collapsible sections, consistent with the Operations screen design patterns.
2. **Bottom Navigation Bar Redesign**: Update the navbar to better complement the new UI design with improved visual hierarchy and consistent styling.

## Glossary

- **Palakat_App**: The Flutter mobile application for church members
- **Song_Book_Screen**: The screen where users browse and search for hymns and songs
- **Bottom_Navigation_Bar**: The persistent navigation component at the bottom of the screen
- **Song_Category**: A grouping of songs by hymnal type (NNBT, KJ, NKB, DSL)
- **Category_Card**: A collapsible card component that groups related items
- **Primary_Color**: The main brand color (teal) from which all other colors are derived
- **Surface_Color**: Background colors for cards, sheets, and containers

## Requirements

### Requirement 1: Song Book Screen Category Organization

**User Story:** As a church member, I want to see song categories organized clearly with collapsible sections, so that I can quickly find hymns from my preferred hymnal without visual clutter.

#### Acceptance Criteria

1. WHEN the Song_Book_Screen loads THEN the Palakat_App SHALL display song categories as collapsible Category_Card components
2. WHEN displaying song categories THEN the Palakat_App SHALL group songs into logical categories (NNBT, KJ, NKB, DSL)
3. WHEN a user taps a category header THEN the Palakat_App SHALL expand that category to show a search-filtered list of songs from that hymnal
4. THE Song_Book_Screen SHALL use the same Category_Card visual pattern as the Operations screen (teal header, neutral background)
5. WHEN no songs match the search query THEN the Palakat_App SHALL display an empty state with clear messaging

### Requirement 2: Song Book Screen Visual Design

**User Story:** As a church member, I want the song book screen to have a clean, calming design consistent with the rest of the app, so that I can focus on finding songs without visual distraction.

#### Acceptance Criteria

1. THE Song_Book_Screen SHALL use the Primary_Color (teal) for category headers and interactive elements only
2. THE Song_Book_Screen SHALL use neutral Surface_Color values for card backgrounds
3. WHEN displaying song cards THEN the Palakat_App SHALL use subtle shadows and rounded corners (16px radius) for depth
4. THE Song_Book_Screen SHALL maintain consistent spacing using an 8px grid system
5. WHEN displaying icons THEN the Palakat_App SHALL use monochromatic icons that match the Primary_Color tonal scale

### Requirement 3: Song Search Integration

**User Story:** As a church member, I want to search for songs while browsing categories, so that I can quickly find specific hymns by title or number.

#### Acceptance Criteria

1. THE Song_Book_Screen SHALL display a search input field at the top of the screen
2. WHEN a user types in the search field THEN the Palakat_App SHALL filter songs across all categories with 500ms debounce
3. WHEN search results are displayed THEN the Palakat_App SHALL show song cards with title, subtitle, and navigation chevron
4. WHEN the search field is cleared THEN the Palakat_App SHALL return to the category view
5. THE search input field SHALL use the Primary_Color for focus states and borders

### Requirement 4: Song Card Interaction

**User Story:** As a church member, I want clear visual feedback when interacting with song cards, so that I know my taps are registered.

#### Acceptance Criteria

1. WHEN a user taps a song card THEN the Palakat_App SHALL display a ripple effect using Primary_Color at 10% opacity
2. THE song cards SHALL display a title, subtitle (hymnal abbreviation), and contextual music icon
3. WHEN a song card is tapped THEN the Palakat_App SHALL navigate to the song detail screen
4. THE song cards SHALL use the same visual pattern as Operation_Item_Card (icon container, content, chevron)

### Requirement 5: Bottom Navigation Bar Visual Redesign

**User Story:** As a user, I want the bottom navigation bar to have a cleaner, more cohesive design, so that navigation feels seamless and consistent with the app's visual language.

#### Acceptance Criteria

1. THE Bottom_Navigation_Bar SHALL use a unified Primary_Color (teal) for all selected states instead of per-tab colors
2. THE Bottom_Navigation_Bar SHALL use neutral colors for unselected states
3. WHEN a navigation item is selected THEN the Palakat_App SHALL display a subtle indicator using Primary_Color at 15% opacity
4. THE Bottom_Navigation_Bar SHALL maintain consistent icon sizing (24px) and label typography
5. THE Bottom_Navigation_Bar SHALL use a subtle top border using Primary_Color at 12% opacity

### Requirement 6: Bottom Navigation Bar Interaction

**User Story:** As a user, I want smooth transitions when navigating between screens, so that the app feels responsive and polished.

#### Acceptance Criteria

1. WHEN a user taps a navigation item THEN the Palakat_App SHALL animate the selection indicator with 400ms duration
2. THE Bottom_Navigation_Bar SHALL always show labels for all navigation items
3. WHEN the user is not authenticated THEN the Palakat_App SHALL hide Operations and Approval navigation items
4. THE Bottom_Navigation_Bar SHALL maintain minimum touch target sizes of 48x48 pixels for all items

### Requirement 7: Category Expansion State

**User Story:** As a church member, I want the app to remember which song categories I've expanded, so that I don't have to re-expand them during my session.

#### Acceptance Criteria

1. WHEN a user expands a song category THEN the Palakat_App SHALL persist that expansion state during the session
2. WHEN the Song_Book_Screen is revisited THEN the Palakat_App SHALL restore the previous category expansion states
3. THE Song_Book_Screen SHALL allow multiple categories to be expanded simultaneously
4. WHEN the app session ends THEN the Palakat_App SHALL reset all category expansion states to collapsed

### Requirement 8: Responsive Layout

**User Story:** As a user on different device sizes, I want the song book screen to adapt appropriately, so that I have a good experience regardless of my device.

#### Acceptance Criteria

1. THE Song_Book_Screen SHALL use flexible layouts that adapt to screen width
2. WHEN the screen width exceeds 600px THEN the Palakat_App SHALL display category cards in a 2-column grid
3. WHEN the screen width is 600px or less THEN the Palakat_App SHALL display category cards in a single column
4. THE Song_Book_Screen SHALL maintain minimum touch target sizes of 48x48 pixels for all interactive elements
