# palakat

A supposedly simple event notifier app

## Routing Conventions

- We use `go_router` for all navigation.
- For Freezed models, pass data via `extra` using `RouteParam`, but serialize with `toJson` on push and reconstruct with `fromJson` in the route.
  - Example push: `context.pushNamed(AppRoute.someDetail, extra: RouteParam(params: { 'model': myModel.toJson() }))`
  - Example route read: `final params = (state.extra as RouteParam?)?.params; final model = MyModel.fromJson(params?['model'] as Map<String, dynamic>);`
- Avoid using query parameters for large JSON payloads in normal in-app flows; prefer `extra` with serialized maps as above. Use query parameters only for deep links.

Applied updates:
- `ApprovalDetailScreen` now accepts a full `Approval` model via `extra`.
- `SongDetailScreen` route now reads a `Song` model via `extra`, and the list passes the full `Song` model.