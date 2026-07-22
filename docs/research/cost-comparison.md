# Cost Comparison: Current Stack (EC2 + Redis + Firebase + Pusher) vs. Full Supabase Port

Research for [#21](https://github.com/meimodev/palakat/issues/21), part of the NestJS-removal evaluation ([#14](https://github.com/meimodev/palakat/issues/14)). All prices read from primary sources on **2026-07-21**; pricing changes, so re-verify before using this for a budget decision more than a few months old.

## Verdict

At every scale modeled (5 to 200 churches), a full Supabase port comes out **roughly 10-15% cheaper on infrastructure** than the current EC2+Redis+Firebase Storage stack — but that gap is noise compared to the dominant line item at every scale: **phone-number SMS verification**, which costs the same (large) amount regardless of which backend wins, because it isn't a Supabase-vs-NestJS question. Cost alone is a weak argument for the migration: it saves real but modest money ($25-135/month depending on scale), it does **not** force a scary Supabase plan tier (Team's $599/month base is not technically required at any modeled scale — Pro's $25/month base is), and the single assumption the whole comparison hinges on (how often a member needs a fresh SMS OTP) can swing the total by hundreds of dollars a month in either direction, dwarfing the hosting decision itself.

## 1. Current stack cost, itemized

Grounded in the EC2 + GitHub Actions deployment and `apps/palakat_backend/package.json`. Where the deployment is silent, the assumption is stated inline.

| Item | Monthly cost | Basis / assumption |
|---|---|---|
| EC2 instance (`t3.small`, on-demand) | ~$19.27 | Guide recommends `t3.small` as "the safer default" for real production (§5.3). $0.0264/hr × 730 hr, `ap-southeast-1` (Singapore) — region not specified in the guide; Singapore assumed as nearest AWS region to Indonesia. [Source](https://instances.vantage.sh/aws/ec2/t3.small), rate corroborated via search 2026-07-21. |
| EBS gp3 20GB root volume | ~$1.60-2 | Guide specifies 20GB gp3 minimum (§5.7). AWS gp3 list price ~$0.08-0.096/GB-mo; not independently verified for `ap-southeast-1`, treated as an estimate. |
| Data transfer out (EC2 egress) | ~$3-5 (pilot) | Not specified by guide. Estimated at pre-launch/pilot traffic; scales with usage — see §5 below. |
| **Redis** | **$0** | The guide is explicit: Redis is **optional** and normally left unconfigured for a single EC2 instance — the app falls back to Socket.IO's in-memory adapter (guide §2, §3.4, §22.6, §23.8). **The current bill does not actually include Redis today**, despite the `@socket.io/redis-adapter` dependency in `package.json` — that dependency is provisioned for a future multi-instance upgrade, not in use. |
| Firebase Storage (Blaze, pay-as-you-go) | ~$0 | Blaze free tier: 5GB stored + 100GB/month downloaded (new-style `*.firebasestorage.app` buckets) or 5GB stored + 1GB/day downloaded (legacy `*.appspot.com` buckets). Pilot-scale document/report/article-cover volume is assumed to fit inside this free tier. [Source: firebase.google.com/pricing](https://firebase.google.com/pricing), read 2026-07-21. |
| Firebase Auth phone verification (SMS) | ~$22.50 (pilot, see §3) | Billed per SMS via Identity Platform phone-auth pricing, tiered by country and monthly volume. Indonesia: Tier 1 (0-99,999/mo) $0.135, Tier 2 (100k-999k) $0.130, Tier 3 (1M+) $0.125. No free tier for production phone auth. [Source: firebase.google.com/docs/phone-number-verification/pricing](https://firebase.google.com/docs/phone-number-verification/pricing), read 2026-07-21. |
| Pusher Beams | $0 (pilot) | Sandbox tier is free up to 1,000 subscribed devices; Startup $29/mo (10,000), Pro $99/mo (50,000), Business $199/mo (115,000), Premium $399/mo (250,000). [Source: pusher.com/beams/pricing](https://pusher.com/beams/pricing/), read 2026-07-21. |
| Supabase Postgres (already paid today) | $0-25 | Assumption: Free tier ($0) is plausible pre-launch at pilot scale (500MB DB, 5GB egress are enough), but a production financial workflow arguably already wants Pro's daily backups ($25/mo base) — this line is existing spend either way and is **not** a migration cost. |
| Vercel (palakat_admin + palakat_super_admin, per `vercel.json`) | $20 | Hobby plan is explicitly "for personal, non-commercial use" — a church-management admin panel doesn't qualify, so Pro is required at $20/user/month (1 seat assumed). [Source: vercel.com/pricing](https://vercel.com/pricing), read 2026-07-21. |

**Pilot-scale current stack total: ~$66-92/month** (range depends on whether Supabase Postgres is already Free or Pro). See §3 for moderate/optimistic scaling of each line.

## 2. Projected Supabase cost — which plan tier do the required features actually force?

Primary source: [supabase.com/pricing](https://supabase.com/pricing), read 2026-07-21.

| Feature | Free | Pro ($25/mo base) | Team ($599/mo base) |
|---|---|---|---|
| Database branching | Not available | Available, pay-per-use: **$0.01344/branch-hour** on top of Pro | Same pay-per-use pricing |
| Daily backups | None | **7-day retention, included** | 14-day retention |
| Point-in-time recovery | Not available | $100/mo per 7 days retention (add-on, any paid plan) | Same add-on pricing |
| Realtime concurrent peak connections | 200 included | **500 included, then $10 per 1,000** | Same, volume discounts at Enterprise |
| Realtime messages/month | 2M included | **5M included, then $2.50/M** | Same |
| Edge Function invocations/month | 500K included | **2M included, then $2/M** | Same |
| Storage included | 1GB | **100GB, then $0.0213/GB** | Same |
| Egress included | 5GB | **250GB, then $0.09/GB** | Same |
| Log retention (API & DB) | 1 day | **7 days** | **28 days** |
| Compute size | Shared, fixed | Any add-on size, billed hourly (Micro $10/mo ... 16XL $3,730/mo) | Same |
| SOC2 / SSO / HIPAA | No | No | No (Enterprise only) |

**Finding: nothing in Palakat's required feature list technically forces Team.** Branching and daily backups — the two features most people assume require a big-plan jump — are gated at **Pro ($25/month base)**, not Team. Compute size, which is what actually scales with churches/members, is decoupled from plan tier entirely: you can run a `16XL` compute add-on on the $25/month Pro plan. The only things Team buys over Pro are longer log retention (28 vs 7 days), SSO, and support SLAs — compliance/organizational decisions, not hard technical gates. If Palakat wants 28-day audit log retention for the financial-approval workflow, that's a deliberate $599/month choice, not a forced one.

## 3. Projected cost at three scales

### Usage assumptions (stated explicitly — pre-launch, so these are projections, not measurements)

- **Peak concurrent realtime connections** ≈ 10% of total members online simultaneously (Sunday-service traffic pattern for a church app).
- **Realtime messages/month**: the backend's ~100 socket RPC actions were inspected directly (`apps/palakat_backend/src/realtime/rpc-router.service.ts`) — **only 13 of the 138 distinct action names are broadcast/push-style events** (`activity.created`, `finance.updated`, `approval.approved`, etc.); the rest (`*.get`, `*.list`, `*.create`, `*.update`, `*.delete`) are request/response RPC, not fan-out messages. A Supabase port would naturally split this: CRUD moves to PostgREST/Edge Functions (counted as Edge Function invocations, not Realtime messages), and only the push-style subset maps to Supabase Realtime Broadcast/Postgres Changes. Modeled as ~200 mutating actions/church/month × ~5 subscribers/event.
- **Edge Function invocations/month**: if the full 230-endpoint surface (132 REST + ~100 RPC) is ported, modeled as 30 calls/session × 8 sessions/month × 60% MAU.
- **Storage**: reports (PDF/Excel), documents, article covers, songbook files — modeled at ~4MB/member/month cumulative stored.
- **Egress**: report downloads, images, API responses — modeled at ~40MB/member/month, scaled linearly with members (the same assumption is applied to both stacks for consistency).
- **Phone SMS verification**: modeled at 1 verification per member per 3 months (login-persistence assumption — no re-auth telemetry exists pre-launch). **This is the single assumption the whole comparison is most sensitive to; see §5.**

| Scale | Churches / Members | Peak realtime conns | Realtime msgs/mo | Edge Fn calls/mo | Storage | Egress |
|---|---|---|---|---|---|---|
| Pilot | 5 / 500 | 50 | ~5K | ~72K | ~2GB | ~20GB |
| Moderate | 50 / 5,000 | 500 | ~50K | ~720K | ~20GB | ~200GB |
| Optimistic | 200 / 20,000 | 2,000 | ~200K | ~2.9M | ~80GB | ~800GB |

### Supabase platform cost (Postgres + Realtime + Edge Functions + Storage, Pro base)

| Scale | Base | Compute add-on | Realtime overage | Edge Fn overage | Storage overage | Egress overage | **Platform total** |
|---|---|---|---|---|---|---|---|
| Pilot | $25 | Micro, covered by included $10 credit → $0 | $0 (within 500) | $0 (within 2M) | $0 (within 100GB) | $0 (within 250GB) | **~$25/mo** |
| Moderate | $25 | Small $15 − $10 credit = $5 | ~$10 (at the 500 threshold) | $0 (within 2M) | $0 (within 100GB) | $0 (within 250GB, but at 80% of quota — watch item) | **~$40/mo** |
| Optimistic | $25 | Medium $60 − $10 credit = $50 | ~$20 (2,000 conns, 1,500 over) | ~$2 (2.9M, 900K over) | ~$1 (marginal) | **~$50** (800GB, 550GB over × $0.09) | **~$147/mo** |

Egress is the line that actually surprises at optimistic scale, exactly as the ticket flagged — it's the only overage that's a meaningful fraction of the platform total. Realtime message quota, by contrast, is a non-issue at every modeled scale: a church app's mutation volume is nowhere near consumer-app levels, and 5M/month included on Pro comfortably covers even the 40x-pilot optimistic case.

## 4. Line items that survive the port regardless — not creditable as savings

- **Push notifications**: Pusher Beams or FCM — someone has to deliver push. Beams: Sandbox free (pilot) → Startup $29/mo (moderate) → Pro $99/mo (optimistic). [pusher.com/beams/pricing](https://pusher.com/beams/pricing/)
- **SMS provider for phone auth** (sibling ticket [#19](https://github.com/meimodev/palakat/issues/19)): whether it stays on Firebase/Identity Platform or moves to Supabase Auth + Twilio/Vonage/MessageBird, someone still pays a telco per verification. Supabase Auth does not include free SMS — it requires bringing your own SMS provider, at comparable per-message economics to what Firebase already charges. This is the single largest line item at every scale (§5) and it is **identical** under both architectures.
- **Vercel** for `palakat_admin` and `palakat_super_admin`: $20/month (Pro, 1 seat), unaffected by the backend decision.

## 5. Side-by-side monthly cost table

| | Pilot (5 churches / 500 members) | Moderate (50 churches / 5,000 members) | Optimistic (200 churches / 20,000 members) |
|---|---|---|---|
| **Current stack** (EC2+Redis+Firebase+Beams+Supabase DB+Vercel) | $66-92 | ~$354 | ~$1,269 |
| — EC2 compute+EBS+egress | ~$24 | ~$50 (t3.medium) | ~$188 (2× t3.medium + ALB + Redis, egress-heavy) |
| — Redis | $0 (not provisioned) | $0 (still single-instance viable) | ~$15 (multi-instance scale-out) |
| — Firebase Storage | ~$0 | ~$5 | ~$20 |
| — Firebase Auth SMS | ~$22.50 | ~$225 | ~$867 |
| — Pusher Beams | $0 | $29 | $99 |
| — Supabase Postgres (existing) | $0-25 | $25 | $75 (Pro + Medium compute) |
| — Vercel | $20 | $20 | $20 |
| **Full Supabase port** (platform + Beams/FCM + SMS + Vercel) | ~$67.50 | ~$314 | ~$1,133 |
| — Supabase platform (DB+Realtime+Edge Fn+Storage) | $25 | $40 | $147 |
| — Beams | $0 | $29 | $99 |
| — SMS (unchanged provider economics) | $22.50 | $225 | $867 |
| — Vercel | $20 | $20 | $20 |
| **Delta (current − Supabase)** | **≈ −$1 to +$25 (a wash)** | **≈ +$40 cheaper on Supabase** | **≈ +$136 cheaper on Supabase** |

Supabase is never *more* expensive than the current stack in this model — the crossover the ticket asked about doesn't really appear at these scales, because EC2's own fixed costs (a second instance, an ALB, Redis for socket scale-out) start compounding at exactly the point where Supabase's usage-based overages are still small. The savings are real but proportionally small (roughly 10-15% of the total bill at every scale) because **SMS dominates the total at every scale** and doesn't move with the platform decision.

## 6. Sensitivity — the assumption this answer rests on

The **phone re-verification frequency assumption (1 SMS OTP per member per 3 months)** is what the entire verdict is most sensitive to — far more than any Supabase-specific quota:

- At the modeled 1-per-3-months rate, SMS costs $22.50 → $225 → $867/month across the three scales — already the single largest line item at moderate and optimistic scale, on **both** stacks.
- If actual re-auth behavior is closer to once every 6-12 months (long-lived JWT sessions, infrequent app reinstalls), SMS cost drops 2-4x, and the total bill at optimistic scale falls from ~$1,100-1,300/month to the $400-600/month range — a bigger swing than the entire Supabase-vs-EC2 hosting decision produces in either direction.
- Conversely, if the product design requires phone re-verification on every financial-approval action (plausible for a security-sensitive multi-step approval flow), SMS cost could be 3-5x higher than modeled, at which point it would dominate the total bill so completely that the infra hosting question becomes cost-irrelevant.

There is no production telemetry to pin this down pre-launch. Before treating "cost" as a settled driver for the NestJS-removal decision, it's worth instrumenting actual phone re-auth frequency in the very first weeks after launch — that number matters more to the monthly bill than whether Postgres RPC lives behind NestJS or Supabase's PostgREST.

## Sources

- Supabase pricing: https://supabase.com/pricing (read 2026-07-21)
- Supabase compute/disk add-ons: https://supabase.com/docs/guides/platform/compute-and-disk (read 2026-07-21)
- Supabase egress billing: https://supabase.com/docs/guides/platform/manage-your-usage/egress (read 2026-07-21)
- Supabase Realtime quotas: https://supabase.com/docs/guides/realtime/quotas (read 2026-07-21)
- AWS EC2 on-demand pricing (t3 family): https://aws.amazon.com/ec2/pricing/on-demand/ and https://instances.vantage.sh/aws/ec2/t3.small (read 2026-07-21)
- AWS ElastiCache pricing: https://aws.amazon.com/elasticache/pricing/ and https://instances.vantage.sh/aws/elasticache/cache.t4g.micro (read 2026-07-21)
- Firebase pricing (Blaze plan, Storage): https://firebase.google.com/pricing (read 2026-07-21)
- Firebase phone-number verification pricing (Indonesia tiers): https://firebase.google.com/docs/phone-number-verification/pricing (read 2026-07-21)
- Pusher Beams pricing: https://pusher.com/beams/pricing/ (read 2026-07-21)
- Vercel pricing: https://vercel.com/pricing (read 2026-07-21)
- Repo: the EC2 deployment workflow, `apps/palakat_backend/package.json`, `apps/palakat_backend/prisma/schema.prisma`, `apps/palakat_backend/src/realtime/rpc-router.service.ts` (RPC action surface inspected directly, 2026-07-21)
