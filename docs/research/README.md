# Supabase-migration research — closed

Evidence gathered for [#14](https://github.com/meimodev/palakat/issues/14), the evaluation of porting
`palakat_backend` off NestJS onto Supabase.

**That evaluation is closed.** [ADR-0006](../adr/0006-no-go-on-removing-nestjs.md) (2026-07-22) answered
[#26](https://github.com/meimodev/palakat/issues/26) **no-go**. These six documents are kept as the record
behind that verdict — ADR-0006 cites each of them by ticket number. **They are not plans. Do not action them.**

The single live plan for the backend is
[`../palakat-backend-gcp-cloud-run-migration-plan.md`](../palakat-backend-gcp-cloud-run-migration-plan.md).

| File | Ticket | Why it mattered |
|---|---|---|
| `edge-functions-reports.md` | [#17](https://github.com/meimodev/palakat/issues/17) | **The decisive finding.** pdfkit and exceljs cannot run on Deno, so a Node worker survives a "go" — and the port would have ended on three platforms, not one. |
| `realtime-rpc-replacement.md` | [#18](https://github.com/meimodev/palakat/issues/18) | Supabase Realtime has no request/response primitive — the RPC router is deleted under either verdict. |
| `auth-phone-jwt.md` | [#19](https://github.com/meimodev/palakat/issues/19) | Firebase stays as phone verifier either way; Twilio Indonesia SMS is dearer than Firebase. |
| `cron-and-queue.md` | [#20](https://github.com/meimodev/palakat/issues/20) | The scheduler replacement. Its timezone trap survives into the live plan §8.2. |
| `cost-comparison.md` | [#21](https://github.com/meimodev/palakat/issues/21) | "Database Rp 0" has a 5 GB egress ceiling. Prices read 2026-07-21 — **stale, re-verify before budgeting.** |
| `push-notifications.md` | [#22](https://github.com/meimodev/palakat/issues/22) | FCM over Pusher Beams. Now decision 13 + [ADR-0003](../adr/0003-push-splits-by-category.md). |

Related evidence kept outside this folder: [`../palakat-backend-rls-feasibility.md`](../palakat-backend-rls-feasibility.md)
([#24](https://github.com/meimodev/palakat/issues/24)) and its runnable SQL in [`../spike/rls/`](../spike/rls/).
