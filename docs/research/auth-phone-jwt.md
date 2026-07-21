# What replaces Firebase phone auth plus the custom multi-audience JWT?

Research for [issue #19](https://github.com/meimodev/palakat/issues/19), part of the Supabase-migration evaluation ([issue #14](https://github.com/meimodev/palakat/issues/14)). Blocks the RLS prototype ([issue #24](https://github.com/meimodev/palakat/issues/24)).

Scope note: pre-launch, no live users — no bcrypt/password migration is in scope anywhere in this document.

## Verdict

Supabase Auth can replace the password/JWT half of the stack cleanly (native `signInWithPassword`, a Custom Access Token Hook for `app_metadata`-based roles, configurable access-token lifetime). The phone half is the risk: none of Supabase's built-in SMS providers (Twilio, MessageBird, Vonage, Textlocal) are validated in these docs for Indonesia pricing below Firebase's own rate, and Twilio's own published Indonesia SMS price (**$0.4414/segment** + $0.05 Verify fee ≈ **$0.49/verification**) is *more expensive* than Firebase's own Identity Platform SMS rate for Indonesia (**$0.35/SMS**, first 10/day free). Keeping Firebase as the phone verifier and layering Supabase Auth on top via **Third-Party Auth** is viable (Firebase is an officially supported third-party provider) and avoids the SMS cost question entirely, but it means `auth.uid()` doesn't work (Firebase UIDs aren't UUIDs), the Custom Access Token Hook doesn't run for these tokens (Firebase issues its own JWT, bypassing Supabase's hook pipeline), and role/audience claims must continue to be injected via Firebase custom claims exactly as `syncClaims()` does today. Recommendation: prototype the Firebase-third-party-auth path first (lowest migration delta, zero new SMS spend), not the native-Supabase-phone-provider path.

## 1. Supabase Auth phone/SMS providers for Indonesian numbers

Supabase Auth's phone login supports four SMS providers: **MessageBird, Twilio, Vonage, and Textlocal** (community-supported). WhatsApp as a delivery channel is only available via Twilio/Twilio Verify. Default OTP request throttle is once per 60 seconds, with a 1-hour expiry. Supabase itself adds no markup — cost is 100% pass-through to whichever provider you configure.
Source: [supabase.com/docs/guides/auth/phone-login](https://supabase.com/docs/guides/auth/phone-login), [.../phone-login/twilio](https://supabase.com/docs/guides/auth/phone-login/twilio), [.../phone-login/messagebird](https://supabase.com/docs/guides/auth/phone-login/messagebird), [.../phone-login/vonage](https://supabase.com/docs/guides/auth/phone-login/vonage)

**Cost delta — Indonesia, per verification:**

| Provider | Price | Free tier | Source |
|---|---|---|---|
| Firebase Auth (current, via Identity Platform) | **$0.35** / SMS | First 10 SMS/day (~300/month) free, per project | [cloud.google.com/identity-platform/pricing](https://cloud.google.com/identity-platform/pricing) — official table row: "Indonesia (ID) — $0.35 / 1 count, per 1 month / project" |
| Twilio (outbound SMS to ID, international long code) | $0.4414 / segment | None documented | [twilio.com/en-us/sms/pricing/id](https://www.twilio.com/en-us/sms/pricing/id) — table row "International Numbers — $0.4414" |
| Twilio Verify (adds a flat verification fee on top of the channel fee) | +$0.05 / successful verification | Volume discounts available, no free tier | [authgear.com/post/twilio-verify-pricing-and-alternatives](https://www.authgear.com/post/twilio-verify-pricing-and-alternatives/) (secondary source — Twilio doesn't publish this fee on the SMS pricing page itself; treat as lower-trust, verify with Twilio sales before committing) |
| Twilio Verify total for Indonesia (estimate) | **≈ $0.49** / verification | — | Derived from the two rows above |
| MessageBird / Vonage for Indonesia | Not determined | — | Neither provider publishes Indonesia SMS rates on a page reachable without an account login; would need direct verification before a go decision |

**Bottom line on cost:** switching from Firebase to a Supabase-native SMS provider (Twilio, the only one with public Indonesia pricing found) would *increase* per-verification cost by roughly 40%, not decrease it. Firebase phone auth is not literally free at low volume as the ticket assumed — official pricing shows **no unconditional free tier**, only 10 free SMS/day, and Indonesia is billed at $0.35/SMS beyond that from day one of production use. This corrects the ticket's premise; it does not change the conclusion that Firebase is currently cheaper than the Twilio alternative.

One separate Firebase product must not be confused with this: **Firebase Phone Number Verification (PNV)**, a newer silent/carrier-based verification product, prices Indonesia at $0.135/verification but is carrier-restricted to **Telkomsel only** in Indonesia ("Coverage within each region depends on carrier support"). The current codebase uses classic Firebase Auth phone sign-in (SMS OTP via `verifyIdToken`), not PNV, so this carrier restriction does not apply to what's running today — flagging it only so it isn't accidentally proposed as a cheaper substitute; it would silently fail for the ~magnitude of Indonesian users on Indosat, XL, Tri, or Smartfren. Source: [firebase.google.com/docs/phone-number-verification/pricing](https://firebase.google.com/docs/phone-number-verification/pricing) (official, table + "Supported carriers" section).

No primary source found (Supabase docs or provider docs) that speaks specifically to Indonesian deliverability quality (e.g., DLT-style local sender-ID registration requirements, as exist for India). Supabase's own docs only give a generic warning: "look up and follow the regulations of countries where you operate," citing India's TRAI DLT rules as the one concrete example. Whether Indonesia (Kominfo) has an equivalent registered-sender requirement for OTP SMS was not verified against a primary source in this pass — flag as open risk, not a settled fact.

## 2. Can Firebase remain the phone verifier while Supabase Auth holds the session?

Yes — via **Supabase Third-Party Auth**, which officially lists Firebase Auth as a supported provider (alongside Clerk, Auth0, AWS Cognito, WorkOS). Source: [supabase.com/docs/guides/auth/third-party/overview](https://supabase.com/docs/guides/auth/third-party/overview), [supabase.com/docs/guides/auth/third-party/firebase-auth](https://supabase.com/docs/guides/auth/third-party/firebase-auth)

How it works: Firebase keeps doing everything it does today (phone OTP, `verifyIdToken`, session issuance) — you point Supabase at your Firebase project ID (`config.toml`: `[auth.third_party.firebase]`), and Supabase's Data API/PostgREST trusts Firebase's own ID tokens directly as bearer tokens, the same way it trusts its own. No token exchange call, no second sign-in step.

Setup (from the official Firebase-Auth third-party guide):
1. Register the Firebase Project ID in Supabase's Authentication settings.
2. `supabase/config.toml`: `[auth.third_party.firebase]` with `enabled = true`, `project_id = "<id>"`.
3. If self-hosting, add restrictive RLS policies on every exposed table to block tokens from *other* Firebase projects (Supabase's Data API will otherwise trust any Firebase-issued token with a valid `iss`).
4. Every Firebase user needs the custom claim `role: 'authenticated'` set (via Admin SDK / a Cloud Function on user creation) — Firebase JWTs don't carry a `role` claim by default, and Supabase's Postgres role selection depends on it.
5. Flutter client: initialize `Supabase.initialize(... accessToken: () async => FirebaseAuth.instance.currentUser?.getIdToken())` — Supabase's client SDK calls this callback to source the bearer token instead of managing its own session.

Client-library nuance: this is **not** the same code path as `signInWithIdToken()`. That method's provider list (confirmed from the official Dart reference) is Google, Apple, Facebook (also Kakao/Keycloak per Supabase's broader docs) — **Firebase is not in it**. Third-Party Auth uses the `accessToken` callback pattern instead, which is provider-agnostic on the Firebase side — it works identically whether the underlying Firebase sign-in method was phone, email, or Google, so today's phone-only flow is fully covered. Source: [supabase.com/docs/reference/dart/auth-signinwithidtoken](https://supabase.com/docs/reference/dart/auth-signinwithidtoken), [supabase.com/docs/guides/auth/third-party/firebase-auth](https://supabase.com/docs/guides/auth/third-party/firebase-auth)

Cost: Third-Party Auth is billed per **Monthly Active (Third-Party) User**: free up to 50,000 MAU/month, then $0.00325/MAU beyond quota — no per-request or per-token-verification fee. Source (secondary, aggregation of Supabase's published quota change and MAU pricing page — worth confirming on `supabase.com/docs/guides/platform/manage-your-usage/monthly-active-users-third-party` before committing budget): [github.com/orgs/supabase/discussions/33959](https://github.com/orgs/supabase/discussions/33959).

Two real costs of this path, not covered by the ticket's framing:
- **Firebase Admin/Auth keeps running forever** — this is not a "remove NestJS, remove Firebase" outcome, it's "remove NestJS, keep Firebase, add Supabase." Two auth systems in production instead of one.
- **`auth.uid()` does not work.** Firebase UIDs are opaque ~28-char strings, not UUIDs, so `auth.uid()` (which parses `sub` as a UUID) breaks. RLS policies must read `auth.jwt()->>'sub'` directly and any FK column referencing "the current user" must be `text`, not `uuid references auth.users(id)` — because **no row is created in `auth.users`** for third-party-authenticated users. This is the single most load-bearing fact for issue #24 (the RLS prototype): the entire native-Supabase RLS idiom of `user_id uuid references auth.users(id)` does not apply if this path is chosen.
- The **Custom Access Token Hook does not run** for third-party tokens — Firebase mints its own JWT outside Supabase's hook pipeline entirely. Role/claim injection must stay in Firebase custom claims (`setCustomUserClaims`), i.e. today's `syncClaims()` in `auth.service.ts` doesn't get deleted, it becomes the permanent claims-authoring mechanism.

Confirmed RLS pattern for validating a Firebase third-party token (from the official docs, verbatim):
```sql
create policy "Restrict access to Supabase Auth and Firebase Auth for project ID <firebase-project-id>"
  on table_name
  as restrictive
  to authenticated
  using (
    (auth.jwt()->>'iss' = 'https://<project-ref>.supabase.co/auth/v1')
    or
    (
        auth.jwt()->>'iss' = 'https://securetoken.google.com/<firebase-project-id>'
        and
        auth.jwt()->>'aud' = '<firebase-project-id>'
     )
  );
```
Source: [supabase.com/docs/guides/auth/third-party/firebase-auth](https://supabase.com/docs/guides/auth/third-party/firebase-auth)

## 3. Mapping `role` and the three audiences (`user`/`admin`/`super-admin`) onto Supabase

Two Supabase-reserved claims cannot be repurposed the way the current code uses them:

- **`aud`** — in native Supabase Auth this is always `"authenticated"` (or `"anon"`). It is not a free-form multi-tenant field the way the current `aud: user|admin|super-admin` is used. In the Firebase-third-party path, `aud` is pinned to the Firebase project ID (used for cross-project isolation, see policy above) — also not available for audience tagging.
- **`role`** — this is the **Postgres role** PostgREST assumes when running the request (normally `anon` or `authenticated`), not a business/authorization role. The Custom Access Token Hook example in Supabase's own docs shows it *can* be overwritten from `app_metadata.role`, but doing so means picking a real Postgres role to switch into — not the intended use for a three-tier business role like `USER`/`ADMIN`/`SUPER_ADMIN`.

The documented, correct home for business-role and audience data is **`app_metadata`** (server-writable only — via the service-role key or a Custom Access Token Hook — and therefore safe to key RLS off). `user_metadata` is explicitly documented as user-editable and **unsafe** for authorization decisions (per the Supabase skill's own security checklist).

**Recommended claim shape**, produced by a Custom Access Token Hook that reads `public."Account"` by the authenticated user's identity and stamps role/audience into `app_metadata`:

```json
{
  "iss": "https://<project-ref>.supabase.co/auth/v1",
  "aud": "authenticated",
  "role": "authenticated",
  "sub": "<supabase-auth-uuid>",
  "exp": 1234567890,
  "iat": 1234567890,
  "aal": "aal1",
  "session_id": "<uuid>",
  "email": null,
  "phone": "+6281234567890",
  "is_anonymous": false,
  "app_metadata": {
    "account_id": 42,
    "account_role": "ADMIN",
    "app_scope": "admin_web",
    "church_id": 7,
    "membership_id": 101
  },
  "user_metadata": {
    "name": "Jane Doe"
  }
}
```

- `account_role` replaces today's `role` (AccountRole enum: `USER`/`ADMIN`/`SUPER_ADMIN`) — read by RLS as `(auth.jwt() -> 'app_metadata' ->> 'account_role')`.
- `app_scope` replaces today's `aud` (`user`/`admin`/`super-admin`) — same lookup pattern. Named `app_scope` rather than `aud` specifically to avoid colliding with the reserved claim.
- `account_id` bridges Supabase's UUID `sub` back to the existing integer `Account.id` primary key (see gap table below — this is the biggest schema-level decision this ticket surfaces).
- `church_id`/`membership_id` are proposed additions so RLS policies can scope church data without a join on every query — worth validating against issue #24's actual policy needs rather than treating as final.

Official example hook (minimal claim-passthrough form) confirming the mechanism:
```sql
create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
as $$
  declare
    original_claims jsonb;
    new_claims jsonb;
    claim text;
  begin
    original_claims = event->'claims';
    new_claims = '{}'::jsonb;
    foreach claim in array array['iss','aud','exp','iat','sub','role','aal','session_id','email','phone','is_anonymous'] loop
      if original_claims ? claim then
        new_claims = jsonb_set(new_claims, array[claim], original_claims->claim);
      end if;
    end loop;
    return jsonb_build_object('claims', new_claims);
  end
$$;
```
Required/reserved claims that cannot be removed: `iss`, `aud`, `exp`, `iat`, `sub`, `role`, `aal`, `session_id`, `email`, `phone`, `is_anonymous`. Optional: `jti`, `nbf`, `app_metadata`, `user_metadata`, `amr`.
Source: [supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook](https://supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook)

Note: this hook only fires for **native Supabase Auth** sign-ins (password, native phone OTP). If the Firebase-third-party path from §2 is chosen instead, this entire mechanism is bypassed and claims must be injected via Firebase custom claims (`setCustomUserClaims`) — the two approaches are not composable for the same sign-in.

## 4. Can all three Flutter apps share one Supabase Auth instance, with admin surfaces kept separate?

Yes, structurally — one Supabase project, one Auth instance, three Flutter clients (`palakat`, `palakat_admin`, `palakat_super_admin`) all authenticating against it, distinguished by the `app_scope`/`account_role` claims proposed above. This is the same shape as today (one JWT secret, `aud` used to tag the issuing app).

**What stops a `user` token from being used against admin endpoints:** nothing, automatically. There is no Supabase-native concept of per-client-app token scoping (no OAuth "audience/scope" enforcement point once NestJS's `RolesGuard` is gone). Enforcement moves entirely to two places:
- **RLS policies** on every table, keyed off `app_metadata.account_role` — this is exactly what issue #24 has to design, and why this ticket blocks it.
- **Edge Functions**, for anything that isn't plain table CRUD (the `ClientStrategy`/machine-to-machine header-auth pattern in `client.strategy.ts` has no Supabase equivalent at all — no doc found describing an analog; it would need to be rebuilt as a service-role-keyed Edge Function).

This is a materially different security posture than today's: currently a single `RolesGuard` class centrally enforces `@Roles()` on every controller method. Post-migration, the equivalent check has to be correctly re-implemented on **every RLS policy and every Edge Function individually** — one missed policy is a silent authorization hole, not a compile error. Not a blocker, but the audit surface changes shape completely; issue #24 needs to account for this when designing the prototype.

The alternative — genuinely separate Supabase projects per app tier — was considered and rejected as impractical here: all three apps read/write the same church/membership/finance data, so splitting projects would require cross-project data replication or a Foreign Data Wrapper, which is strictly more complexity than the single-project + RLS approach for no isolation benefit that RLS doesn't already provide.

## 5. Refresh token behaviour, session lifetime, and the current 7-day model

- **Access token (JWT) lifetime**: configurable, default **1 hour**. Docs recommend not exceeding 1 hour and not going below 5 minutes. Configured in project Auth settings (dashboard). Source: [supabase.com/docs/guides/auth/sessions](https://supabase.com/docs/guides/auth/sessions)
- **Refresh tokens**: opaque strings, not JWTs. Per the docs: "refresh tokens never expire but can only be used once" — i.e. there's no direct "7-day TTL" knob. A refresh token is valid indefinitely until: the user signs out, an admin revokes the session, or **reuse-detection** fires.
- **Reuse detection**: a refresh token can be reused only within a 10-second window (default, not recommended to change) or if it's the *parent* of the currently active token (covers network-retry edge cases). Any reuse outside those two exceptions **terminates the whole session** and revokes every refresh token belonging to it. This is a strictly different (and generally stronger) model than the current single `refreshTokenHash`/`refreshTokenJti` compare-and-rotate implemented by hand in `auth.service.ts`.
- **Time-boxed sessions** and **inactivity timeout** are the two configurable options that can approximate "session dies after 7 days": "Time-box user sessions" forces termination after a fixed duration regardless of activity; "Inactivity timeout" terminates a session that hasn't been refreshed within N days. Both are documented as **available on Pro plan and above**, not the Free plan — this is a real gap if the team intends to stay on Supabase's free tier: the exact 7-day hard cap the current code enforces isn't reproducible on Free.
Source: [supabase.com/docs/guides/auth/sessions](https://supabase.com/docs/guides/auth/sessions)

So: the 7-day refresh window is *expressible*, but only via a Pro-plan-gated setting (inactivity timeout), not via a JWT claim like today's `typ: 'refresh'` + 7-day `expiresIn`. On Free plan, the closest available behavior is "refresh tokens live until reuse is detected or the user signs out" — functionally longer-lived than today's 7 days unless the Pro feature is enabled.

## 6. `supabase_flutter` (Dart) gaps vs JS

- **Phone OTP**: `signInWithOtp()` supports a `phone:` parameter in the Dart SDK, same surface as JS — no gap found for the basic send/verify OTP flow itself.
- **`signInWithIdToken()`**: Dart signature is `signInWithIdToken({required OAuthProvider provider, required String idToken, String? accessToken, String? nonce, String? captchaToken})`. Provider enum covers Google, Apple, Facebook (and per broader docs, Kakao/Keycloak) — **Firebase is not a valid `OAuthProvider` value in either SDK**, so this method is a dead end for the Firebase-third-party path regardless of platform; that path uses the `accessToken` callback on `Supabase.initialize()` instead (shown in §2), which **is** present in the Dart SDK with an explicit code sample in Supabase's own docs. No JS-only gap identified here — the callback mechanism is documented Flutter-first in the Firebase guide.
- Custom claims / `app_metadata`: read the same way in Dart as JS (`supabase.auth.currentUser?.appMetadata`), no SDK gap found.
- No other Dart-vs-JS asymmetry was surfaced in the docs reviewed for this ticket; this is not an exhaustive parity audit and a dedicated pass would be needed before implementation if fine-grained OTP-channel options (WhatsApp, resend semantics) matter.

## Claim/guard mapping table

| Current (`auth.service.ts` / guards) | Supabase equivalent | Gap |
|---|---|---|
| `sub` = integer `Account.id` | `sub` = Supabase Auth UUID (native) **or** Firebase UID string (third-party) | Neither is the existing integer PK. Every FK currently typed against an integer account id needs a bridging strategy — either migrate `Account.id` to UUID, or keep the integer PK and carry it in `app_metadata.account_id` (proposed above) and join through that everywhere RLS needs it. This is the single biggest schema decision buried in this ticket. |
| `aud` ∈ `user`\|`admin`\|`super-admin` | Reserved; pinned to `authenticated` (native) or the Firebase project ID (third-party) | Audience tagging moves to `app_metadata.app_scope`. Every client's auth guard logic (Flutter `user`/`admin`/`super-admin` apps) must switch from reading `aud` to reading `app_metadata.app_scope`. |
| `role` (`AccountRole`: USER/ADMIN/SUPER_ADMIN) | Reserved; Postgres role selector (`anon`/`authenticated`) | Business role moves to `app_metadata.account_role`. Custom Access Token Hook can inject it (native path only — does not run for Firebase third-party tokens). |
| `typ` (`user` vs `refresh`) distinguishing token type | Not needed — Supabase separates access (JWT) and refresh (opaque string) natively, client SDK manages the split | Removed entirely; simplification, not a gap. |
| 7-day refresh TTL, `refreshTokenHash`/`refreshTokenExpiresAt`/`refreshTokenJti` columns, manual bcrypt-compare rotation | Refresh tokens don't expire by default; rotation + reuse-detection is built into GoTrue; hard time caps need "Time-box sessions"/"Inactivity timeout" | Those two caps are **Pro-plan gated**, not available on Free. Exact 7-day behavior isn't reproducible without a paid plan. |
| Firebase phone OTP + `syncClaims`/`firebaseSignIn`/`firebaseRegister` | Either (a) native Supabase phone OTP via Twilio/MessageBird/Vonage, or (b) keep Firebase, add Supabase Third-Party Auth | (a) costs more per SMS for Indonesia than Firebase today (§1); (b) keeps two auth systems running and breaks `auth.uid()`/hook-based claims (§2). Neither is a clean win; needs a product decision, not just a technical one. |
| bcrypt password sign-in (`signIn`, `adminSignIn`, `superAdminSignIn`, `changePassword`) | Native `signInWithPassword` / `updateUser` (password change), GoTrue owns hashing | Clean 1:1 swap. No migration needed per pre-launch scope. |
| `ClientStrategy` (x-username/x-password machine auth) | No documented equivalent | Needs a bespoke Edge Function using the service-role key; not covered by any Supabase Auth feature. |
| `RolesGuard` + `@Roles()` decorator, centrally enforced per-controller | RLS policy per table + per-Edge-Function checks, keyed off `app_metadata.account_role` | Enforcement point moves from one central Nest guard to N distributed RLS policies/functions. Bigger audit surface; exactly what issue #24 must design carefully. |

## Sources consulted

- [supabase.com/docs/guides/auth/phone-login](https://supabase.com/docs/guides/auth/phone-login) — provider list, rate limits
- [supabase.com/docs/guides/auth/phone-login/twilio](https://supabase.com/docs/guides/auth/phone-login/twilio), [.../messagebird](https://supabase.com/docs/guides/auth/phone-login/messagebird), [.../vonage](https://supabase.com/docs/guides/auth/phone-login/vonage)
- [supabase.com/docs/guides/auth/third-party/overview](https://supabase.com/docs/guides/auth/third-party/overview) — supported providers, MAU billing model
- [supabase.com/docs/guides/auth/third-party/firebase-auth](https://supabase.com/docs/guides/auth/third-party/firebase-auth) — setup steps, Flutter `accessToken` callback code, RLS `iss`/`aud` policy example
- [supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook](https://supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook) — reserved claims, hook SQL example
- [supabase.com/docs/guides/auth/sessions](https://supabase.com/docs/guides/auth/sessions) — JWT/refresh lifetime, reuse detection, time-boxed sessions
- [supabase.com/docs/guides/auth/managing-user-data](https://supabase.com/docs/guides/auth/managing-user-data) — `app_metadata` vs `user_metadata`
- [supabase.com/docs/reference/dart/auth-signinwithidtoken](https://supabase.com/docs/reference/dart/auth-signinwithidtoken) — Dart `signInWithIdToken` signature and provider list
- [cloud.google.com/identity-platform/pricing](https://cloud.google.com/identity-platform/pricing) — official Firebase/Identity Platform SMS pricing, Indonesia row, 10-free-per-day rule
- [firebase.google.com/docs/phone-number-verification/pricing](https://firebase.google.com/docs/phone-number-verification/pricing) — official PNV pricing/carrier table (used only to rule PNV out, not as the active-product price)
- [twilio.com/en-us/sms/pricing/id](https://www.twilio.com/en-us/sms/pricing/id) — official Twilio Indonesia SMS pricing table
- [github.com/orgs/supabase/discussions/33959](https://github.com/orgs/supabase/discussions/33959) — Third-Party Auth MAU quota increase (secondary/community source, flagged as lower-trust)
- [authgear.com/post/twilio-verify-pricing-and-alternatives](https://www.authgear.com/post/twilio-verify-pricing-and-alternatives/) — Twilio Verify flat fee (secondary source, flagged as lower-trust; not found on Twilio's own pricing page)
- Repo: `apps/palakat_backend/src/auth/auth.service.ts`, `strategies/jwt.strategy.ts`, `strategies/client.strategy.ts`, `roles.guard.ts`, `roles.decorator.ts`, `firebase/firebase-admin.service.ts`, `prisma/schema.prisma`
