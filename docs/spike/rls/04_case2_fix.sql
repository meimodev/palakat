-- #24 CASE 2 remedy: invitation-accept cannot be a policy, because the write
-- creates the very Membership row that every other policy derives scope from.
-- It becomes a security definer RPC instead. Mirrors rpc-router.service.ts:1690-1720.

-- Members may no longer INSERT Membership at all; only this function may.
drop policy if exists membership_insert_own_church on "Membership";
revoke insert on "Membership" from authenticated;

create or replace function public.accept_membership_invitation(invitation_id int)
returns "Membership"
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  acct int := app.current_account_id();
  inv  "MembershipInvitation";
  col  "Column";
  m    "Membership";
begin
  if acct is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;

  select * into inv from "MembershipInvitation"
   where id = invitation_id for update;

  if not found                    then raise exception 'Invitation not found'      using errcode = 'P0002'; end if;
  if inv."inviteeId" <> acct      then raise exception 'Not allowed'               using errcode = '42501'; end if;
  if inv.status <> 'PENDING'      then raise exception 'Invitation already resolved' using errcode = '23505'; end if;

  select * into col from "Column" where id = inv."columnId";
  if col."churchId" is distinct from inv."churchId" then
    raise exception 'columnId belongs to a different church' using errcode = '22023';
  end if;

  if exists (select 1 from "Membership" where "accountId" = acct) then
    raise exception 'Account already has a membership' using errcode = '23505';
  end if;

  insert into "Membership" ("accountId","churchId","columnId",baptize,sidi,"updatedAt")
  values (acct, inv."churchId", inv."columnId", inv.baptize, inv.sidi, now())
  returning * into m;

  update "MembershipInvitation"
     set status = 'APPROVED', "rejectedAt" = null, "rejectedReason" = null,
         "updatedAt" = now()
   where id = inv.id;

  return m;
end $$;

revoke execute on function public.accept_membership_invitation(int) from public, anon;
grant  execute on function public.accept_membership_invitation(int) to authenticated;
