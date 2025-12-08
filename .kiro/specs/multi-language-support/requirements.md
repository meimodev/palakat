# Requirements Document

## Introduction

This document specifies the requirements for implementing multi-language support (Indonesian and English) across the Palakat mobile app and Palakat Admin web panel. The feature enables users to switch between languages, with Indonesian as the default language given the target audience (Indonesian churches). The implementation will use Flutter's built-in localization system with the `intl` package for message extraction and formatting.

## Glossary

- **Locale**: A combination of language and optional country code (e.g., `id_ID` for Indonesian, `en_US` for English)
- **ARB File**: Application Resource Bundle - JSON-like files used by Flutter's `intl` package to store translated strings
- **L10n**: Abbreviation for "localization" (L + 10 letters + n)
- **I18n**: Abbreviation for "internationalization" (I + 18 letters + n)
- **LocaleProvider**: A Riverpod provider that manages the current locale state across the application
- **AppLocalizations**: Generated class that provides access to localized strings
- **Palakat Mobile**: The Flutter mobile application (`apps/palakat`)
- **Palakat Admin**: The Flutter web admin panel (`apps/palakat_admin`)
- **Palakat Shared**: The shared package containing common code (`packages/palakat_shared`)

## Requirements

### Requirement 1

**User Story:** As a user, I want to select my preferred language (Indonesian or English), so that I can use the application in my native language.

#### Acceptance Criteria

1. WHEN the application starts for the first time THEN the Palakat Mobile SHALL default to Indonesian locale
2. WHEN the application starts for the first time THEN the Palakat Admin SHALL default to Indonesian locale
3. WHEN a user navigates to the account/settings screen THEN the system SHALL display a language selection option
4. WHEN a user selects a different language THEN the system SHALL immediately update all visible text to the selected language
5. WHEN a user selects a language THEN the system SHALL persist the selection to local storage
6. WHEN the application restarts THEN the system SHALL restore the previously selected language from local storage

### Requirement 2

**User Story:** As a developer, I want a centralized localization infrastructure in the shared package, so that both apps can reuse translations and maintain consistency.

#### Acceptance Criteria

1. WHEN localization files are organized THEN the Palakat Shared package SHALL contain the ARB files for both languages
2. WHEN a translation key is defined THEN the system SHALL generate type-safe accessor methods via `intl` code generation
3. WHEN a new translation is added THEN the developer SHALL add it to both `intl_id.arb` and `intl_en.arb` files
4. WHEN code generation runs THEN the system SHALL produce `AppLocalizations` class with all translation methods
5. WHEN a translation key exists in one ARB file but not the other THEN the code generation SHALL fail with a descriptive error

### Requirement 3

**User Story:** As a developer, I want consistent access to localized strings throughout the codebase, so that I can easily internationalize UI components.

#### Acceptance Criteria

1. WHEN accessing translations in a widget THEN the developer SHALL use `AppLocalizations.of(context)` or a Riverpod provider
2. WHEN a translation requires parameters THEN the ARB file SHALL define placeholders using ICU message format
3. WHEN a translation includes pluralization THEN the ARB file SHALL use ICU plural syntax
4. WHEN a translation includes date/time formatting THEN the system SHALL use locale-aware formatters from `intl` package
5. WHEN a translation includes number/currency formatting THEN the system SHALL use locale-aware formatters from `intl` package

### Requirement 4

**User Story:** As a user, I want all UI text to be properly translated, so that I have a consistent experience in my chosen language.

#### Acceptance Criteria

1. WHEN displaying navigation labels THEN the system SHALL show translated text for all menu items
2. WHEN displaying form labels and hints THEN the system SHALL show translated text for all input fields
3. WHEN displaying button text THEN the system SHALL show translated text for all buttons
4. WHEN displaying error messages THEN the system SHALL show translated error descriptions
5. WHEN displaying status labels (approved, pending, rejected) THEN the system SHALL show translated status text
6. WHEN displaying date/time values THEN the system SHALL format them according to the selected locale

### Requirement 5

**User Story:** As a developer, I want the locale state to be managed via Riverpod, so that it integrates seamlessly with the existing state management architecture.

#### Acceptance Criteria

1. WHEN the locale changes THEN the LocaleProvider SHALL notify all listening widgets
2. WHEN the LocaleProvider initializes THEN the system SHALL load the persisted locale from local storage
3. WHEN no persisted locale exists THEN the LocaleProvider SHALL default to Indonesian (`id`)
4. WHEN the locale is updated THEN the LocaleProvider SHALL persist the new value to local storage
5. WHEN serializing the locale preference THEN the system SHALL store only the language code string

### Requirement 6

**User Story:** As a user, I want the language setting to be easily accessible, so that I can change it without navigating through many screens.

#### Acceptance Criteria

1. WHEN viewing the account screen in Palakat Mobile THEN the system SHALL display a language selector
2. WHEN viewing the account screen in Palakat Admin THEN the system SHALL display a language selector
3. WHEN tapping the language selector THEN the system SHALL show available language options (Indonesian, English)
4. WHEN a language option is selected THEN the system SHALL close the selector and apply the change

### Requirement 7

**User Story:** As a developer, I want a pretty printer for locale serialization, so that I can test round-trip consistency of locale persistence.

#### Acceptance Criteria

1. WHEN serializing a locale to storage THEN the system SHALL convert it to a string representation
2. WHEN deserializing a locale from storage THEN the system SHALL parse the string back to a Locale object
3. WHEN round-tripping a locale through serialization THEN the resulting locale SHALL equal the original locale

