-- #24 RLS prototype — policies for the three cases named in the ticket.

-- ===========================================================================
-- CASE 1: finance approval with override
--   finance.service.ts:373-412   self-approve: same church, own row, UNCONFIRMED
--   finance.service.ts:557-600   override:     same church, any row, any status
--   rpc-router.service.ts:2168   override also needs ops.approval.finance.override
--                                AND an aud='admin' session
-- ===========================================================================
alter table "RevenueApprover" enable row level security;
alter table "RevenueApprover" force row level security;
alter table "Revenue"         enable row level security;

drop policy if exists revenue_read_own_church on "Revenue";
create policy revenue_read_own_church on "Revenue"
  for select to authenticated
  using ("churchId" = (select app.current_church_id()));

drop policy if exists approver_read_own_church on "RevenueApprover";
create policy approver_read_own_church on "RevenueApprover"
  for select to authenticated
  using (exists (
    select 1 from "Revenue" r
    where r.id = "revenueId"
      and r."churchId" = (select app.current_church_id())
  ));

-- self-approve: own row, still pending, and cannot be moved back to pending
drop policy if exists approver_self_decide on "RevenueApprover";
create policy approver_self_decide on "RevenueApprover"
  for update to authenticated
  using (
    "membershipId" = (select app.current_membership_id())
    and status = 'UNCONFIRMED'
    and exists (
      select 1 from "Revenue" r
      where r.id = "revenueId"
        and r."churchId" = (select app.current_church_id())
    )
  )
  with check (
    "membershipId" = (select app.current_membership_id())
    and status <> 'UNCONFIRMED'
    and exists (
      select 1 from "Revenue" r
      where r.id = "revenueId"
        and r."churchId" = (select app.current_church_id())
    )
  );

-- override: skips both the self-only and the single-shot checks
drop policy if exists approver_admin_override on "RevenueApprover";
create policy approver_admin_override on "RevenueApprover"
  for update to authenticated
  using (
    (select app.has_permission('ops.approval.finance.override'))
    and (select app.is_admin_aud())
    and exists (
      select 1 from "Revenue" r
      where r.id = "revenueId"
        and r."churchId" = (select app.current_church_id())
    )
  )
  with check (
    (select app.has_permission('ops.approval.finance.override'))
    and (select app.is_admin_aud())
    and exists (
      select 1 from "Revenue" r
      where r.id = "revenueId"
        and r."churchId" = (select app.current_church_id())
    )
  );

-- RLS is row-level only. The app's DTO whitelists `status`; the equivalent
-- narrowing under PostgREST is a column grant, not a policy.
revoke update on "RevenueApprover" from authenticated;
grant update (status, "updatedAt") on "RevenueApprover" to authenticated;
grant select on "RevenueApprover", "Revenue" to authenticated;

-- ===========================================================================
-- CASE 2: membership invitation respond / approve
--   rpc-router.service.ts:1581  respond: invitee only, PENDING only
--   rpc-router.service.ts:1885  admin approve: SUPER_ADMIN only
-- ===========================================================================
alter table "MembershipInvitation" enable row level security;
alter table "MembershipInvitation" force row level security;
alter table "Membership"           enable row level security;

drop policy if exists invitation_read_mine on "MembershipInvitation";
create policy invitation_read_mine on "MembershipInvitation"
  for select to authenticated
  using (
    "inviteeId" = (select app.current_account_id())
    or "inviterId" = (select app.current_account_id())
    or (select app.is_elevated())
  );

drop policy if exists invitation_respond on "MembershipInvitation";
create policy invitation_respond on "MembershipInvitation"
  for update to authenticated
  using (
    "inviteeId" = (select app.current_account_id())
    and status = 'PENDING'
  )
  with check (
    "inviteeId" = (select app.current_account_id())
    and status <> 'PENDING'
  );

-- The naive membership policy: you may only touch rows in your own church.
-- This is what makes the APPROVE branch fail — see 03_tests.sql.
drop policy if exists membership_read_own_church on "Membership";
create policy membership_read_own_church on "Membership"
  for select to authenticated
  using ("churchId" = (select app.current_church_id()));

drop policy if exists membership_insert_own_church on "Membership";
create policy membership_insert_own_church on "Membership"
  for insert to authenticated
  with check ("churchId" = (select app.current_church_id()));

grant select, update on "MembershipInvitation" to authenticated;
grant select, insert on "Membership" to authenticated;

-- ===========================================================================
-- CASE 3: article management
--   article.service.ts:269  findAllAdmin -> assertAdmin(user); NO church scope.
--   Article has no churchId column. This is a global CMS, not church-scoped.
-- ===========================================================================
alter table "Article" enable row level security;
alter table "Article" force row level security;

drop policy if exists article_read_published on "Article";
create policy article_read_published on "Article"
  for select to anon, authenticated
  using (status = 'PUBLISHED' or (select app.is_elevated()));

drop policy if exists article_admin_write on "Article";
create policy article_admin_write on "Article"
  for all to authenticated
  using ((select app.is_elevated()))
  with check ((select app.is_elevated()));

grant select on "Article" to anon, authenticated;
grant insert, update, delete on "Article" to authenticated;
