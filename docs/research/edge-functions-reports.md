# Can Supabase Edge Functions produce Palakat's PDF and Excel reports?

**Ticket:** [meimodev/palakat#17](https://github.com/meimodev/palakat/issues/17) · Part of [#14](https://github.com/meimodev/palakat/issues/14) (NestJS → Supabase evaluation)
**Date:** 2026-07-21

## Verdict

**No.** Report generation should not move to Supabase Edge Functions. `pdfkit` fights Deno's filesystem sandbox at the exact code path Palakat depends on (font loading), `exceljs` has never had supported Deno compatibility, and even if both were coaxed to run, Edge Functions cap CPU time at **2 seconds per request** and memory at **256MB** — limits a multi-section, multi-page church financial report will realistically exceed regardless of library choice. `EdgeRuntime.waitUntil()` does not lift these caps; it only postpones worker retirement within the same wall-clock/CPU/memory budget. Report generation needs to keep living in a real Node/long-running process — most pragmatically, a small retained worker service rather than a full NestJS monolith.

## Load-bearing facts

1. **pdfkit hits Deno's permission sandbox on its core code path.** A Supabase user's Edge Function using `pdfkit` (identical library to `report.service.ts`) failed with `PermissionDenied: Deno.readFileSync is blocklisted` when constructing `new PDFDocument(...)` — pdfkit reads bundled `.afm` font files off disk via `fs.readFileSync` at render time, and Deno's sandbox blocked that read. The reporter says it "had been working for months" then broke with no code change, and was only fixed after **Supabase support intervened on the backend** — i.e., not something a project owner can reliably fix or depend on themselves.
   Source: [supabase/supabase#30378](https://github.com/supabase/supabase/issues/30378) (closed, labeled `bug`, `external-issue`)

2. **exceljs has no supported Deno path.** Two feature requests asking for Deno support were closed without the maintainers merging compatibility work. The blockers cited were core to how exceljs works: a Node `Buffer`/`__proto__` polyfill issue, missing `node:crypto` (in older Deno), and — closer to Palakat's own usage — an internal `stream.write(await entry.async('nodebuffer'))` call in the XLSX zip-writing path that a community fork had to patch to get running at all. No official fix landed; workarounds require an unofficial fork loaded from a CDN.
   Sources: [exceljs/exceljs#1302](https://github.com/exceljs/exceljs/issues/1302), [exceljs/exceljs#2045](https://github.com/exceljs/exceljs/issues/2045)

3. **Current Edge Function hard limits (Supabase official docs, current as of this research):**
   - Memory: **256MB** max
   - Wall-clock duration: **150s** (Free plan), **400s** (Paid plans)
   - **CPU time: 2s per request** (actual time on CPU; does not include async I/O like DB queries or network calls)
   - Request idle timeout: 150s (a 504 is returned if no response is sent in time)
   - Exceeding any of these terminates the worker with a `546 Resource Limit` error (`WORKER_RESOURCE_LIMIT`, formerly `WORKER_LIMIT`)
   Sources: [Limits](https://supabase.com/docs/guides/functions/limits), [Status codes](https://supabase.com/docs/guides/functions/status-codes)

4. **Background tasks don't raise the ceiling.** `EdgeRuntime.waitUntil()` lets a function keep working after it has responded to the client, but it explicitly **does not extend** the wall-clock, CPU, or memory limits above — the worker is still killed once any of those caps is hit. A `beforeunload` handler exists only so the function can flush state before that forced shutdown.
   Source: [Background Tasks](https://supabase.com/docs/guides/functions/background-tasks)

5. **No native long-running compute tier exists on the Supabase platform.** Supabase Queues (pgmq-backed, [Queues docs](https://supabase.com/docs/guides/queues)) and Supabase Cron ([Cron docs](https://supabase.com/docs/guides/cron)) provide durable message storage and scheduling on top of Postgres, but the thing that actually *processes* a dequeued message still has to be an Edge Function (subject to fact #3) or an external worker — Supabase does not offer a generic "long-running/queued compute worker" product separate from Edge Functions.

## What breaks, mapped to Palakat's actual code

- `apps/palakat_backend/src/report/report.service.ts` (2,221 lines) imports `* as PDFDocument from 'pdfkit'` and `* as ExcelJS from 'exceljs'`, and builds output through `PassThrough` streams held **entirely in memory** (not streamed to disk) — this is exactly the pattern that stresses the 256MB memory ceiling on anything but a small report.
- The service renders QR codes (`qrcode` package), embeds a church letterhead/logo image (`buildGmimLetterhead`, `getGmimLogoBuffer`), and produces multi-section documents (birthdays, congregation lists, services, activities, and — the largest case — `FINANCIAL` reports pulling from `Report`/`ReportJob` with `ReportGenerateType.FINANCIAL`). A church-wide financial report iterates all transactions for a period; pdfkit page composition + font subsetting + per-row QR/image work for that volume is very unlikely to complete inside a 2-second CPU budget, even though the *wall-clock* budget (150–400s) looks generous — CPU time is the binding constraint, and it explicitly excludes only I/O wait, not render/layout work.
- `report-queue.service.ts` (532 lines) polls a `ReportJob` table every 10s and writes incremental `progress` percentages while a job runs. That pattern assumes a long-lived process that can update progress *during* generation — the opposite of Edge Functions' single-invocation, resource-capped model. Reproducing it faithfully on Edge Functions would require chunking a single report's generation across many discrete invocations coordinated through the DB, which is a substantial rewrite of the render pipeline, not a lift-and-shift.
- `document-renderer.ts` also uses `pdfkit`, so it inherits the same font-loading/sandbox risk as `report.service.ts`.

## Alternatives considered

| Option | Assessment |
|---|---|
| **Retain a small dedicated worker/service** (not the whole NestJS app — just the report module, e.g. as a slim Node/Bun process or container) | **Recommended.** Reuses `report.service.ts`/`report-queue.service.ts` almost unmodified — no rewrite risk. Runs pdfkit/exceljs in their native Node environment, so the fragility in facts #1–2 never applies. Since the app is pre-launch with no live users, this can be deployed cheaply (a single small always-on container on Fly.io/Render/a VM, or even a scheduled job) polling the same Postgres DB Supabase would host. This does not require keeping all of NestJS — only this module's compute needs a real Node runtime. |
| **Generate reports client-side in Flutter** (`pdf` / `printing` and `excel`/`syncfusion_flutter_xlsio` Dart packages) | Viable for smaller reports, avoids server limits entirely, but requires re-implementing the layout logic in `report.service.ts` (2,221 lines of formatting, Indonesian date/currency logic, letterhead branding, QR embedding) in Dart, and shifts CPU cost onto user devices — a risk for large financial reports on lower-end phones. Loses a natural server-side artifact/audit trail unless reports are also uploaded after client-side generation. |
| **Third-party render service** (e.g., a hosted PDF/Excel rendering API called from an Edge Function) | Sidesteps Deno's library limits, but sends congregation financial data to a third-party vendor — a privacy/trust concern for a church finance feature — and adds a new external dependency and cost the app doesn't currently have. |
| **Different output format** (e.g., server returns structured data, client prints/exports) | Doesn't fully solve the Excel-fidelity requirement for financial exports, and still needs *something* to produce a byte-exact PDF for official documents. |

**Recommendation:** keep report generation in a real Node process. Concretely, carve the `report` module out as its own minimal service (drop the rest of NestJS if desired, but keep this one piece off Edge Functions) rather than porting `report.service.ts`/`report-queue.service.ts` to Deno. This is the lowest-risk path: it preserves working, tested code and sidesteps both the library-compatibility fragility (facts #1–2) and the hard resource ceilings (facts #3–4) that a Deno-only architecture cannot avoid today.

## Sources

- [supabase/supabase#30378 — pdfkit `PermissionDenied: Deno.readFileSync is blocklisted`](https://github.com/supabase/supabase/issues/30378)
- [exceljs/exceljs#1302 — Deno 1.0 support (closed, unresolved)](https://github.com/exceljs/exceljs/issues/1302)
- [exceljs/exceljs#2045 — Deno support (closed, unresolved)](https://github.com/exceljs/exceljs/issues/2045)
- [Supabase Docs: Edge Functions Limits](https://supabase.com/docs/guides/functions/limits)
- [Supabase Docs: Background Tasks](https://supabase.com/docs/guides/functions/background-tasks)
- [Supabase Docs: Status codes (546 Resource Limit)](https://supabase.com/docs/guides/functions/status-codes)
- [Supabase Docs: Managing dependencies (npm/Node compat in Edge Functions)](https://supabase.com/docs/guides/functions/dependencies)
- [Supabase Docs: Queues](https://supabase.com/docs/guides/queues)
- [Supabase Docs: Cron](https://supabase.com/docs/guides/cron)
- [Supabase Docs: Ephemeral Storage (`/tmp`)](https://supabase.com/docs/guides/functions/ephemeral-storage)
- [Deno Docs: Node and npm Compatibility](https://docs.deno.com/runtime/fundamentals/node/)
- [Supabase Pricing](https://supabase.com/pricing)

**Lower-trust / not cited as fact, informational only:**
- [GitHub Discussion supabase#22002 — "Edge functions don't explicitly state any limits"](https://github.com/orgs/supabase/discussions/) — cited only to note that request/response body size is *not* documented by Supabase; no numeric claim was taken from it.

## Repo files consulted

- `apps/palakat_backend/src/report/report.service.ts`
- `apps/palakat_backend/src/report/report-queue.service.ts`
- `apps/palakat_backend/src/document/document-renderer.ts`
- `apps/palakat_backend/prisma/schema.prisma` (`Report`, `ReportJob`, `ReportFormat`, `ReportJobStatus`, `ReportGenerateType`)
