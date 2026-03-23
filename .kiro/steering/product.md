# Product

Palakat is a church management platform with multiple apps targeting different user roles:

- `apps/palakat` — Mobile app (iOS/Android) for church members. Handles authentication, activities, notifications, finance, approvals, publishing, and more.
- `apps/palakat_admin` — Web admin panel for church administrators.
- `apps/palakat_super_admin` — Web super admin panel for platform-level management.
- `apps/palakat_backend` — Backend service (Node.js/separate stack).

Core capabilities include phone-based OTP authentication (Firebase), push notifications (Pusher Beams + FCM), activity scheduling/alarms, real-time socket updates, file transfers, and localization (Indonesian/English).
