---
status: accepted
date: 2026-07-22
relates-to: "#26"
---

# Uploads: constrain at signing, verify at finalize

Today the backend streams uploaded bytes itself and enforces limits as they arrive:
`MAX_FILE_BYTES` 25 MB, `MAX_ARTICLE_COVER_BYTES` 5 MB checked against
`session.receivedBytes` (`rpc-router.service.ts:931`), `contentType` required to start with
`image/` for covers (:842), and the file extension inferred server-side rather than taken
from the client. A lying client is caught mid-upload.

Moving to Cloud Run makes streaming uploads through the backend expensive — every
megabyte becomes billable request-seconds and tmpfs memory — so the client should upload
directly to storage. That deletes the enforcement point.

**A signed URL from `firebaseAdmin.bucket().file().getSignedUrl()` is a GCS URL, and
Firebase Storage security rules do not apply to it.** Rules are not the fallback. Whatever
enforcement survives has to be built deliberately.

**Decision:** two-sided enforcement.

1. **At signing.** Bind `x-goog-content-length-range` and the expected content type into
   the signed URL, so GCS itself rejects an oversized or mistyped upload without the
   backend seeing a byte. Keep issuing the storage path server-side — the client never
   chooses where its object lands.
2. **At finalize.** The client calls a finalize endpoint after uploading. The server reads
   the object's **real** metadata from GCS, re-checks size and content type against what
   actually landed, and only then writes the `FileManager` row.

Objects never finalized are swept by the daily orphan job introduced in Phase 3.

## Why the finalize round trip is worth it

Without it, the `FileManager` row has to be written when the URL is issued, which means
`sizeInKB` records what the client *declared* and every abandoned upload leaves a row
pointing at nothing. `FileManager` is `@@unique([bucket, path])` and scoped to `churchId`
— it is the record other domain objects hang off (`Report`, `Document`, `Activity`), so a
row that disagrees with storage is worse than a missing one.

Writing the row only after reading real metadata makes it impossible for the two to
disagree.

## Consequences

- One extra round trip per upload, which is cheap against not shuttling the bytes at all.
- The orphan sweep becomes load-bearing rather than a nicety — an unfinalized object is
  now the normal representation of a failed upload, not an anomaly.
- Enforcement is split across two places. Both must be changed together when a limit
  changes, and the signing-side constraint is the one that is easy to forget because
  nothing fails visibly without it.
