-- #24 RLS prototype — fixture with two churches so cross-church leaks are testable.
-- Ids are in the 9000 band to stay clear of the seeded rows.

begin;

delete from "RevenueApprover" where id >= 9000;
delete from "Revenue" where id >= 9000;
delete from "MembershipInvitation" where id >= 9000;
delete from "MembershipPosition" where id >= 9000;
delete from "Membership" where id >= 9000;
delete from "Account" where id >= 9000;
delete from "ChurchPermissionPolicy" where "churchId" in (1, 2);
delete from "Column" where id >= 9000;
delete from "CashAccount" where id >= 9000;

-- accounts (authUserId is the JWT sub the policies key off)
insert into "Account" (id, name, phone, role, "isActive", gender, "maritalStatus", dob, "authUserId", "updatedAt")
values
  (9001, 'A Treasurer', '+6280000009001', 'USER',        true, 'MALE', 'SINGLE', '1990-01-01', '00000000-0000-0000-0000-000000009001', now()),
  (9002, 'A ChurchAdm', '+6280000009002', 'USER',        true, 'MALE', 'SINGLE', '1990-01-01', '00000000-0000-0000-0000-000000009002', now()),
  (9003, 'A Member',    '+6280000009003', 'USER',        true, 'MALE', 'SINGLE', '1990-01-01', '00000000-0000-0000-0000-000000009003', now()),
  (9004, 'B ChurchAdm', '+6280000009004', 'USER',        true, 'MALE', 'SINGLE', '1990-01-01', '00000000-0000-0000-0000-000000009004', now()),
  (9005, 'Invitee',     '+6280000009005', 'USER',        true, 'MALE', 'SINGLE', '1990-01-01', '00000000-0000-0000-0000-000000009005', now()),
  (9006, 'Platform SA', '+6280000009006', 'SUPER_ADMIN', true, 'MALE', 'SINGLE', '1990-01-01', '00000000-0000-0000-0000-000000009006', now());

insert into "Column" (id, name, "churchId", "updatedAt")
values (9001, 'Kolom B1', 2, now());

insert into "Membership" (id, "accountId", "churchId", "columnId", "updatedAt")
values
  (9001, 9001, 1, 1,    now()),
  (9002, 9002, 1, 1,    now()),
  (9003, 9003, 1, 2,    now()),
  -- churchId null on purpose: exercises the Column fallback in current_church_id()
  (9004, 9004, null, 9001, now());

-- church 2 positions (church 1 already has ids 1..4)
insert into "MembershipPosition" (id, name, "churchId", "membershipId", "updatedAt")
values
  (9001, 'Admin Gereja', 2, 9004, now());

update "MembershipPosition" set "membershipId" = 9001 where id = 3; -- Bendahara  -> A Treasurer
update "MembershipPosition" set "membershipId" = 9002 where id = 4; -- Admin Gereja -> A ChurchAdm

-- permission policies, shaped exactly like ChurchPermissionPolicyV1
insert into "ChurchPermissionPolicy" ("churchId", policy, "updatedAt") values
  (1, jsonb_build_object(
        'version', 1,
        'grants', jsonb_build_object(
          'ops.finance.revenue.create',     jsonb_build_object('mode','positionsAny','positionIds', jsonb_build_array(1,2,3)),
          'ops.approval.finance.override',  jsonb_build_object('mode','positionsAny','positionIds', jsonb_build_array(1,4)),
          'ops.approvalRule.manage',        jsonb_build_object('mode','positionsAny','positionIds', jsonb_build_array(1,4))
        )), now()),
  (2, jsonb_build_object(
        'version', 1,
        'grants', jsonb_build_object(
          'ops.approval.finance.override',  jsonb_build_object('mode','positionsAny','positionIds', jsonb_build_array(9001))
        )), now());

insert into "CashAccount" (id, name, "churchId", "updatedAt")
values (9001, 'Kas B', 2, now());

-- revenues: 9001/9002 in church 1, 9003 in church 2
insert into "Revenue" (id, "accountNumber", amount, "churchId", "paymentMethod", "cashAccountId", "updatedAt")
values
  (9001, '4-1000', 500000, 1, 'CASH', (select id from "CashAccount" where "churchId"=1 limit 1), now()),
  (9002, '4-1000', 750000, 1, 'CASH', (select id from "CashAccount" where "churchId"=1 limit 1), now()),
  (9003, '4-1000', 250000, 2, 'CASH', 9001, now());

insert into "RevenueApprover" (id, "membershipId", "revenueId", status, "updatedAt")
values
  (9001, 9001, 9001, 'UNCONFIRMED', now()),  -- A Treasurer's own, pending
  (9002, 9002, 9001, 'UNCONFIRMED', now()),  -- A ChurchAdm's own, pending
  (9003, 9001, 9002, 'APPROVED',    now()),  -- already decided -> single-shot test
  (9004, 9004, 9003, 'UNCONFIRMED', now());  -- church 2

-- invitation into church 1 for an account with no membership yet
insert into "MembershipInvitation" (id, "inviterId", "inviteeId", "churchId", "columnId", status, "updatedAt")
values (9001, 9002, 9005, 1, 1, 'PENDING', now());

select setval(pg_get_serial_sequence('"Account"','id'), 10000, false);
select setval(pg_get_serial_sequence('"Membership"','id'), 10000, false);
select setval(pg_get_serial_sequence('"Revenue"','id'), 10000, false);
select setval(pg_get_serial_sequence('"RevenueApprover"','id'), 10000, false);

commit;
