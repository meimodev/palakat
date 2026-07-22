-- #24 RLS prototype — identity/scope helpers
-- Mirrors ADR-0001: identity comes from the JWT, church scope is resolved live
-- from Membership (never trusted from a token claim).

create schema if not exists app;

-- Supabase auth.users.id is a uuid; Account.id is an int. The port needs a
-- mapping column — there is no external-id field on Account today.
alter table "Account" add column if not exists "authUserId" uuid;
create unique index if not exists account_auth_user_id_key
  on "Account" ("authUserId");

-- ---------------------------------------------------------------- identity
create or replace function app.current_account_id() returns int
language sql stable security definer set search_path = public, pg_temp as $$
  select a.id
  from "Account" a
  where a."authUserId" = nullif(auth.jwt() ->> 'sub', '')::uuid
    and a."isActive"
$$;

create or replace function app.is_elevated() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1 from "Account" a
    where a.id = app.current_account_id()
      and a.role in ('ADMIN', 'SUPER_ADMIN')
  )
$$;

-- The admin app issues tokens with aud='admin'; the member app does not.
-- rpc-router.service.ts:2174 gates override on this in addition to permission.
create or replace function app.is_admin_aud() returns boolean
language sql stable as $$
  select coalesce(auth.jwt() ->> 'aud', '') = 'admin'
$$;

-- ------------------------------------------------------------------- scope
-- Mirrors resolveRequesterMembership(): churchId with a fallback through
-- Column, because Membership.churchId is nullable.
create or replace function app.current_membership_id() returns int
language sql stable security definer set search_path = public, pg_temp as $$
  select m.id from "Membership" m
  where m."accountId" = app.current_account_id()
$$;

create or replace function app.current_church_id() returns int
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(m."churchId", c."churchId")
  from "Membership" m
  left join "Column" c on c.id = m."columnId"
  where m."accountId" = app.current_account_id()
$$;

-- -------------------------------------------------------------- permission
-- Mirrors getEffectivePermissions(): a permission is granted when the
-- requester holds ANY position listed under that key in the church's policy
-- JSON. Elevated roles get every permission.
create or replace function app.has_permission(perm text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.is_elevated() or exists (
    select 1
    from "ChurchPermissionPolicy" p
    join "MembershipPosition" mp
      on mp."membershipId" = app.current_membership_id()
    where p."churchId" = app.current_church_id()
      and p.policy -> 'grants' -> perm -> 'positionIds'
          @> to_jsonb(mp.id)
  )
$$;

grant usage on schema app to authenticated, anon;
grant execute on all functions in schema app to authenticated, anon;
