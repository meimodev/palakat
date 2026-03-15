## Design Context

### Users
Palakat is a multi-surface church operations product used in three primary contexts:

- `apps/palakat` is the mobile experience for church members and operational users handling day-to-day participation, membership, activities, approvals, song book access, notifications, and reminders.
- `apps/palakat_admin` is the church admin workspace for managing members, activities, approvals, finance, reports, documents, and church configuration.
- `apps/palakat_super_admin` is the higher-trust operational surface for global or cross-church management tasks such as song database publishing and other system-level administration.

The core job to be done is to help church teams coordinate people, activities, approvals, finances, documents, and communication clearly and reliably, while keeping routine workflows efficient.

### Brand Personality
Palakat should feel modern, polished, warm, and human.

The interface should communicate:

- trust and reliability for operational and administrative tasks
- clarity and confidence during high-importance workflows
- a welcoming, community-centered tone rather than a cold corporate feel

The existing product already suggests a practical, calm operating style. Future design work should preserve that sense of dependability while raising overall polish and consistency.

### Aesthetic Direction
The current codebase indicates a light-theme-first Material 3 design language with rounded corners, restrained surfaces, and a strong emphasis on readable layouts.

Observed implementation signals to preserve:

- light mode is the primary design target
- mobile brand language is centered around teal
- admin uses a more SaaS-like indigo accent
- super admin uses a teal-accented administrative theme
- Open Sans is used in the mobile app
- spacing follows an 8px rhythm in shared size constants
- cards, inputs, and actions favor soft radii and clean separation
- localization and Indonesian usage are first-class product concerns

Desired overall direction:

- modern and polished, but not flashy
- warm and human, but not playful or childish
- clean and trustworthy, while still efficient for data-heavy admin workflows

### Design Principles
- Prioritize operational clarity. Important tasks, status, hierarchy, and next actions should be obvious at a glance.
- Balance polish with warmth. Use refined spacing, hierarchy, and component consistency, but keep the product approachable and community-centered.
- Design light-first. Optimize the primary experience for light mode and avoid introducing dark-mode-driven decisions unless explicitly requested.
- Respect the existing system. Build on the current Material 3, rounded-surface, and shared-token foundations instead of introducing disconnected visual styles.
- Keep dense workflows usable. Admin and super admin screens should support efficient scanning and management without feeling cramped or harsh.
- Treat localization and responsiveness as core quality requirements. Interfaces should remain readable and composed across Indonesian/English content, smaller widths, and larger text sizes.
