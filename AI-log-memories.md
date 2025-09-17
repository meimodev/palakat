# AI Memories Log

## 2025-09-18T07:48:52+08:00 — Model: Cascade

- Title: Routing convention
  ID: 257c177a-1df3-40ec-9452-0406d8205b29
  Tags: [routing]
  Content: Routing convention: When passing Freezed models between screens using go_router, always pass via extra using RouteParam with model.toJson() on navigation and reconstruct with Model.fromJson() in the route. Avoid queryParameters for normal in-app flows; reserve query params for deep links.

- Title: Navigation preference
  ID: 464f3cfd-2faf-434d-927e-6ae4e48e2691
  Tags: [navigation]
  Content: Navigation preference: Use go_router for all navigation instead of Flutter Navigator throughout the codebase.

- Title: Freezed for models and state
  ID: d2167092-45d6-4291-9910-f42f2c4851cc
  Tags: [models, state, freezed]
  Content: User prefers and requests that all new model or state classes use Freezed. Convert existing simple classes like ApprovalState to Freezed and continue using Freezed consistently across the codebase.

- Title: Consistent label and variable updates
  ID: a828667a-4a43-4a94-9f65-7811aab18fec
  Tags: [naming, ui]
  Content: When UI text labels change, also update related variable names and string references consistently across the codebase.

- Title: Riverpod codegen migration for AccountRepository
  ID: 279f4e5b-172d-424d-bc56-c913738e23a7
  Tags: [riverpod, codegen]
  Content: Successfully converted AccountRepository class from traditional Riverpod Provider to Riverpod with code generation. Key changes:
    1. Added riverpod_annotation import and part directive
    2. Converted class methods to standalone @riverpod annotated functions
    3. Each function now takes a Ref parameter as first argument
    4. Generated providers will be: getSignedInAccountProvider, signInProvider, validateAccountByPhoneProvider
    5. Build runner successfully generated the .g.dart file
    6. Project already had all necessary dependencies: riverpod_annotation, riverpod_generator, build_runner

- Title: Color opacity preference
  ID: 158cc4e3-968e-4cc1-977c-aff2bee55c6a
  Tags: [ui, colors]
  Content: User prefers using withValues method instead of withOpacity when working with color opacity in Flutter. This should be applied consistently across the codebase.

- Title: AI prompt execution logging to AI-log.md
  ID: 36727eab-e6d0-4ab9-b19c-34bdd0133644
  Tags: [preferences, ai_logging, workflow]
  Content: Always generate or append an entry to a root-level AI-log.md after each prompt. Each entry must include the model name (Cascade), the local date/time, and a concise summary of actions taken. Start applying this from now on.

- Title: Log memory state to AI-log-memories.md after each prompt
  ID: 26b93947-a721-47cf-a534-672d20df57a4
  Tags: [preferences, ai_logging, memories]
  Content: After each prompt, also write/update a root-level AI-log-memories.md that reflects the current memory state (titles, tags, content, and IDs). Include model name and timestamp for each update.
