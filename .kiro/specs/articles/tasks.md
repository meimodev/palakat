# Implementation Plan

## Overview

This implementation plan covers the Articles feature for the Palakat church management platform. The feature enables administrators to publish preaching materials and game instructions, which church members can browse, search, filter, and like.

---

## Tasks

### 1. Backend - Database Schema and Module Setup

- [ ] 1.1 Add Article and ArticleLike models to Prisma schema
  - Add Article model with title, content, type, thumbnailUrl, churchId
  - Add ArticleLike model with articleId, accountId, unique constraint
  - Add ArticleType enum (PREACHING, GAME)
  - Add relation from Church to Article
  - Add relation from Account to ArticleLike
  - Run `pnpm run prisma:generate` and `pnpm run db:migrate`
  - _Requirements: 1.1, 1.2_

- [ ] 1.2 Create article module structure
  - Create `src/article/article.module.ts`
  - Create `src/article/article.controller.ts`
  - Create `src/article/article.service.ts`
  - Create `src/article/dto/` directory with DTOs
  - Register module in `app.module.ts`
  - _Requirements: 8.1-8.7_

- [ ] 1.3 Implement article DTOs
  - Create `create-article.dto.ts` with validation decorators
  - Create `update-article.dto.ts` extending PartialType
  - Create `find-articles.dto.ts` with pagination, search, type filter
  - _Requirements: 8.1, 8.3, 8.4_

### 2. Backend - Article CRUD Operations

- [ ] 2.1 Implement article service CRUD methods
  - Implement `findAll` with pagination, search, type filter
  - Implement `findOne` with like status for requesting user
  - Implement `create` with church association
  - Implement `update` with church ownership check
  - Implement `remove` with cascade delete verification
  - _Requirements: 8.1-8.5, 9.1, 9.2_

- [ ]* 2.2 Write property test for article creation
  - **Property 1: Article Creation Stores All Fields**
  - **Validates: Requirements 1.1, 8.3**
  - Generate random valid article data, create, retrieve, verify fields match
  - Create test file: `test/property/article.property.spec.ts`

- [ ]* 2.3 Write property test for timestamps
  - **Property 2: Timestamps Are UTC**
  - **Validates: Requirements 1.2**
  - Verify createdAt and updatedAt are UTC and within reasonable window
  - Add to: `test/property/article.property.spec.ts`

- [ ] 2.4 Implement article controller endpoints
  - Implement GET /articles with query params
  - Implement GET /articles/:id
  - Implement POST /articles
  - Implement PATCH /articles/:id
  - Implement DELETE /articles/:id
  - Add church ownership guards
  - _Requirements: 8.1-8.5, 9.3_

- [ ]* 2.5 Write property test for article update
  - **Property 14: Article Update Persists Changes**
  - **Validates: Requirements 8.4**
  - Generate updates, verify changes are persisted
  - Add to: `test/property/article.property.spec.ts`

### 3. Backend - Search and Filter

- [ ] 3.1 Implement search functionality
  - Add case-insensitive title search in `findAll`
  - Use Prisma `contains` with `mode: 'insensitive'`
  - _Requirements: 4.2, 8.7_

- [ ]* 3.2 Write property test for search
  - **Property 5: Search Returns Case-Insensitive Title Matches**
  - **Validates: Requirements 4.2, 8.7**
  - Generate search terms and titles, verify matching logic
  - Add to: `test/property/article.property.spec.ts`

- [ ] 3.3 Implement type filter
  - Add type filter in `findAll` query
  - _Requirements: 2.5, 5.1_

- [ ]* 3.4 Write property test for pagination
  - **Property 9: Pagination Returns Correct Page**
  - **Validates: Requirements 8.1**
  - Generate varying article counts, verify page boundaries
  - Add to: `test/property/article.property.spec.ts`

### 4. Backend - Like Feature

- [ ] 4.1 Implement like toggle service method
  - Implement `toggleLike` method in article service
  - Check if like exists, create or delete accordingly
  - Return updated like status and count
  - _Requirements: 7.1, 7.3, 8.6_

- [ ] 4.2 Implement like controller endpoint
  - Implement POST /articles/:id/like
  - Return like status and updated count
  - _Requirements: 8.6_

- [ ]* 4.3 Write property test for like count accuracy
  - **Property 3: Like Count Accuracy**
  - **Validates: Requirements 1.3**
  - Generate articles with varying likes, verify count
  - Add to: `test/property/article.property.spec.ts`

- [ ]* 4.4 Write property test for like toggle round-trip
  - **Property 7: Like Toggle Is Idempotent Round-Trip**
  - **Validates: Requirements 7.3, 8.6**
  - Toggle like twice, verify return to original state
  - Add to: `test/property/article.property.spec.ts`

- [ ]* 4.5 Write property test for like status
  - **Property 8: Like Button State Reflects User Status**
  - **Validates: Requirements 7.2, 8.2**
  - Verify isLikedByUser matches like record existence
  - Add to: `test/property/article.property.spec.ts`

### 5. Backend - Data Isolation and Cascade Delete

- [ ] 5.1 Implement church data isolation
  - Add churchId filter to all queries
  - Verify ownership before update/delete
  - Return 403 for cross-church access attempts
  - _Requirements: 9.1, 9.3_

- [ ]* 5.2 Write property test for church data isolation (CRITICAL)
  - **Property 10: Church Data Isolation**
  - **Validates: Requirements 9.1, 9.3**
  - Create articles in multiple churches, verify isolation
  - Create test file: `test/property/article-isolation.property.spec.ts`

- [ ]* 5.3 Write property test for church association
  - **Property 11: Article Associated With Creator's Church**
  - **Validates: Requirements 9.2**
  - Verify created article has correct churchId
  - Add to: `test/property/article-isolation.property.spec.ts`

- [ ]* 5.4 Write property test for cascade delete
  - **Property 4: Cascade Delete Removes Likes**
  - **Validates: Requirements 1.4**
  - Create article with likes, delete, verify likes removed
  - Add to: `test/property/article.property.spec.ts`

### 6. Checkpoint - Backend Tests

- [ ] 6.1 Ensure all backend tests pass
  - Run `pnpm run test:property` for property tests
  - Run `pnpm run test` for unit tests
  - Ensure all tests pass, ask the user if questions arise.

---

### 7. Shared Package - Article Model

- [ ] 7.1 Create Article model in shared package
  - Create `lib/core/models/article.dart` with Freezed
  - Add ArticleType enum
  - Add JSON serialization
  - Run `melos run build:runner`
  - _Requirements: 1.1_

- [ ] 7.2 Create ArticleRepository in shared package
  - Create `lib/core/repositories/article_repository.dart`
  - Implement getArticles, getArticle, createArticle, updateArticle, deleteArticle, toggleLike
  - _Requirements: 8.1-8.6_

- [ ]* 7.3 Write unit tests for Article model
  - Test JSON serialization/deserialization
  - Test ArticleType enum values
  - Create test file: `test/core/models/article_test.dart`

---

### 8. Mobile App - Article List Screen

- [ ] 8.1 Create article feature structure
  - Create `lib/features/article/` directory
  - Create `data/` and `presentations/` subdirectories
  - _Requirements: 3.1_

- [ ] 8.2 Implement ArticleController with Riverpod
  - Create `presentations/article_controller.dart`
  - Implement fetchArticles with pagination
  - Implement loadMore for infinite scroll
  - Implement refresh for pull-to-refresh
  - Implement search and filter state
  - _Requirements: 3.1, 3.5, 3.6, 4.1, 5.1_

- [ ] 8.3 Implement ArticleState with Freezed
  - Create `presentations/article_state.dart`
  - Include articles list, loading, error, pagination state
  - Include search term and filter type
  - _Requirements: 3.1-3.3_

- [ ] 8.4 Implement ArticleScreen UI
  - Create `presentations/article_screen.dart`
  - Add search bar with debounce
  - Add filter chips (All, Preaching, Game)
  - Add article list with infinite scroll
  - Add pull-to-refresh
  - Add loading and error states
  - _Requirements: 3.1-3.6, 4.1, 4.3, 4.4, 5.1-5.4_

- [ ] 8.5 Implement ArticleCard widget
  - Create `presentations/widgets/article_card.dart`
  - Display thumbnail, title, type badge, like count, date
  - Handle tap to navigate to detail
  - _Requirements: 3.4, 6.1_

- [ ]* 8.6 Write property test for article card display
  - **Property 12: Article Card Displays All Required Fields**
  - **Validates: Requirements 3.4**
  - Generate random articles, verify card contains all fields
  - Create test file: `test/features/article/article_property_test.dart`

- [ ]* 8.7 Write property test for filter
  - **Property 6: Filter Returns Correct Type Subset**
  - **Validates: Requirements 2.5, 5.1**
  - Generate articles of different types, verify filter logic
  - Add to: `test/features/article/article_property_test.dart`

### 9. Mobile App - Article Detail Screen

- [ ] 9.1 Implement ArticleDetailController
  - Create `presentations/article_detail_controller.dart`
  - Implement fetchArticle
  - Implement toggleLike with optimistic update
  - _Requirements: 6.2, 7.1-7.5_

- [ ] 9.2 Implement ArticleDetailScreen UI
  - Create `presentations/article_detail_screen.dart`
  - Display thumbnail, title, type, content, like count, date
  - Add like button with active state
  - Add loading and error states
  - Render formatted content (HTML/Markdown)
  - _Requirements: 6.2-6.4, 7.1-7.5_

- [ ]* 9.3 Write property test for detail screen display
  - **Property 13: Detail Screen Displays All Fields**
  - **Validates: Requirements 6.2**
  - Generate random articles, verify detail screen displays all fields
  - Add to: `test/features/article/article_property_test.dart`

### 10. Mobile App - Navigation and Integration

- [ ] 10.1 Add article routes to go_router
  - Add /articles route for list screen
  - Add /articles/:id route for detail screen
  - _Requirements: 3.1, 6.1_

- [ ] 10.2 Add article entry point to app navigation
  - Add article menu item or button to appropriate screen
  - _Requirements: 3.1_

### 11. Checkpoint - Mobile App Tests

- [ ] 11.1 Ensure all mobile app tests pass
  - Run `melos run test` for Flutter tests
  - Ensure all tests pass, ask the user if questions arise.

---

### 12. Admin Panel - Article Management

- [ ] 12.1 Create article feature structure
  - Create `lib/features/article/` directory
  - Create `application/` and `presentation/` subdirectories
  - _Requirements: 2.1_

- [ ] 12.2 Implement ArticleController with Riverpod
  - Create `application/article_controller.dart`
  - Implement fetchArticles with filter
  - Implement createArticle, updateArticle, deleteArticle
  - _Requirements: 2.1-2.5_

- [ ] 12.3 Implement ArticleScreen with data table
  - Create `presentation/screens/article_screen.dart`
  - Add data table with columns: ID, Title, Type, Likes, Created
  - Add filter dropdown for type
  - Add create button
  - Add edit/delete actions per row
  - _Requirements: 2.1, 2.4, 2.5_

- [ ] 12.4 Implement ArticleFormDrawer
  - Create `presentation/widgets/article_form_drawer.dart`
  - Add form fields: title, content (rich text), type dropdown, thumbnail URL
  - Add validation
  - Handle create and edit modes
  - _Requirements: 2.2, 2.3_

- [ ] 12.5 Add delete confirmation dialog
  - Show confirmation before delete
  - _Requirements: 2.4_

### 13. Admin Panel - Navigation and Localization

- [ ] 13.1 Add article routes to admin navigation
  - Add /articles route
  - Add menu item in sidebar
  - _Requirements: 2.1_

- [ ] 13.2 Add localization keys for article feature
  - Add English keys to `intl_en.arb`
  - Add Indonesian keys to `intl_id.arb`
  - Run localization generation
  - _Requirements: 2.1-2.5_

- [ ]* 13.3 Write unit tests for admin article controller
  - Test state transitions
  - Test form validation
  - _Requirements: 2.1-2.5_

### 14. Final Checkpoint

- [ ] 14.1 Run all tests
  - Run `melos run test` for Flutter tests
  - Run `pnpm run test` for backend unit tests
  - Run `pnpm run test:property` for backend property tests
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Backend property tests use `fast-check` library
- Frontend property tests use `kiri_check` library
- All property tests should run minimum 100 iterations
- Church data isolation (Property 10) is critical for security
- Rich text content rendering may require flutter_html or flutter_markdown package

## Quick Reference - Key Commands

### Flutter (from monorepo root)
```bash
melos bootstrap          # Install all dependencies
melos run build:runner   # Generate code (freezed, riverpod, json)
melos run test           # Run all tests
```

### Backend (from apps/palakat_backend)
```bash
pnpm run prisma:generate # Generate Prisma client
pnpm run db:migrate      # Run migrations
pnpm run test            # Run unit tests
pnpm run test:property   # Run property-based tests
```
