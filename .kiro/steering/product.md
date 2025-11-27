# Palakat - Church Activity Management System

Palakat is a church management platform for Indonesian churches (GMIM - Gereja Masehi Injili di Minahasa).

## Core Purpose
- Event notification and activity management for church members
- Administrative tools for church staff and leadership
- Digital song book access (NKB, NNBT, KJ, DSL hymnals)

## Applications

### Mobile App (`apps/palakat`)
- Church member-facing Flutter mobile app
- View upcoming activities and events
- Receive notifications
- Access digital song book
- Submit and track activity approvals
- Firebase authentication (phone-based)

### Admin Panel (`apps/palakat_admin`)
- Web-based Flutter admin dashboard
- Member management
- Activity and event management
- Approval workflows
- Financial tracking (revenue/expenses)
- Document management
- Reporting

### Backend API (`apps/palakat_backend`)
- NestJS REST API
- PostgreSQL database via Prisma ORM
- JWT authentication
- Handles all business logic and data persistence

## Domain Concepts
- **Church**: Organization with members, columns (groups), and positions
- **Membership**: Church member with account, column assignment, and positions
- **Activity**: Events/services with approval workflows (PKB, WKI, PMD, RMJ, ASM bipra types)
- **Approval**: Multi-level approval system with configurable rules
- **Song**: Hymnal entries with parts/verses from various song books
