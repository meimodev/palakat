-- #24 RLS prototype — behavioural tests. Each runs as role `authenticated`
-- with a real JWT claim set, then rolls back.

create or replace function pg_temp.attempt(sub text, aud text, stmt text)
returns text language plpgsql as $$
declare n int; msg text;
begin
  begin
    perform set_config('request.jwt.claims',
      json_build_object('sub', sub, 'aud', aud)::text, true);
    set local role authenticated;
    execute stmt;
    get diagnostics n = row_count;
    reset role;
    -- undo, so each test sees the pristine fixture
    raise exception using errcode = 'UE001',
      message = case when n = 0 then 'BLOCKED(0 rows)' else 'ALLOWED(' || n || ')' end;
  exception
    when sqlstate 'UE001' then
      reset role;
      return sqlerrm;
    when others then
      msg := sqlstate;
      reset role;
      return 'ERROR(' || msg || ')';
  end;
end $$;

\set A_TREAS '''00000000-0000-0000-0000-000000009001'''
\set A_ADMIN '''00000000-0000-0000-0000-000000009002'''
\set A_MEMB  '''00000000-0000-0000-0000-000000009003'''
\set B_ADMIN '''00000000-0000-0000-0000-000000009004'''
\set INVITEE '''00000000-0000-0000-0000-000000009005'''
\set SUPERAD '''00000000-0000-0000-0000-000000009006'''

begin;
select * from (values
-- ============================ CASE 1: finance approval with override
 ('1.1 treasurer approves own pending row',            'ALLOW',
  pg_temp.attempt(:A_TREAS,'member',
   $$update "RevenueApprover" set status='APPROVED' where id=9001$$)),

 ('1.2 treasurer approves someone else''s row',        'DENY',
  pg_temp.attempt(:A_TREAS,'member',
   $$update "RevenueApprover" set status='APPROVED' where id=9002$$)),

 ('1.3 treasurer re-decides an already-APPROVED row',  'DENY',
  pg_temp.attempt(:A_TREAS,'member',
   $$update "RevenueApprover" set status='REJECTED' where id=9003$$)),

 ('1.4 church admin overrides another member''s row',  'ALLOW',
  pg_temp.attempt(:A_ADMIN,'admin',
   $$update "RevenueApprover" set status='APPROVED' where id=9001$$)),

 ('1.5 same admin, but member-app session (aud)',      'DENY',
  pg_temp.attempt(:A_ADMIN,'member',
   $$update "RevenueApprover" set status='APPROVED' where id=9001$$)),

 ('1.6 church-2 admin overrides a church-1 row',       'DENY',
  pg_temp.attempt(:B_ADMIN,'admin',
   $$update "RevenueApprover" set status='APPROVED' where id=9001$$)),

 ('1.7 plain member overrides anything',               'DENY',
  pg_temp.attempt(:A_MEMB,'admin',
   $$update "RevenueApprover" set status='APPROVED' where id=9001$$)),

 ('1.8 override an already-decided row (allowed)',     'ALLOW',
  pg_temp.attempt(:A_ADMIN,'admin',
   $$update "RevenueApprover" set status='REJECTED' where id=9003$$)),

 ('1.9 self-approve reverting to UNCONFIRMED',         'DENY',
  pg_temp.attempt(:A_TREAS,'member',
   $$update "RevenueApprover" set status='UNCONFIRMED' where id=9001$$)),

 ('1.10 reparent own approver onto another revenue',   'DENY',
  pg_temp.attempt(:A_TREAS,'member',
   $$update "RevenueApprover" set "revenueId"=9002, status='APPROVED' where id=9001$$)),

 ('1.11 church-2 admin reads church-1 revenue',        'DENY',
  pg_temp.attempt(:B_ADMIN,'admin',
   $$select 1 from "Revenue" where id=9001$$)),

-- ============================ CASE 2: membership invitation
 ('2.1 invitee rejects own pending invitation',        'ALLOW',
  pg_temp.attempt(:INVITEE,'member',
   $$update "MembershipInvitation" set status='REJECTED' where id=9001$$)),

 ('2.2 unrelated member responds to it',               'DENY',
  pg_temp.attempt(:A_MEMB,'member',
   $$update "MembershipInvitation" set status='APPROVED' where id=9001$$)),

 ('2.3 invitee reads own invitation',                  'ALLOW',
  pg_temp.attempt(:INVITEE,'member',
   $$select 1 from "MembershipInvitation" where id=9001$$)),

 ('2.4 invitee ACCEPTS -> must create Membership',     'ALLOW',
  pg_temp.attempt(:INVITEE,'member',
   $$insert into "Membership" (id,"accountId","churchId","columnId","updatedAt")
     values (9101,9005,1,1,now())$$)),

 ('2.5 invitee self-joins an arbitrary church',        'DENY',
  pg_temp.attempt(:INVITEE,'member',
   $$insert into "Membership" (id,"accountId","churchId","columnId","updatedAt")
     values (9102,9005,2,9001,now())$$)),

-- ============================ CASE 3: articles
 ('3.1 anonymous reads a published article',           'ALLOW',
  pg_temp.attempt('','anon',
   $$select 1 from "Article" where status='PUBLISHED' limit 1$$)),

 ('3.2 plain member lists draft articles',             'DENY',
  pg_temp.attempt(:A_MEMB,'member',
   $$select 1 from "Article" where status='DRAFT' limit 1$$)),

 ('3.3 church admin edits an article',                 'DENY',
  pg_temp.attempt(:A_ADMIN,'admin',
   $$update "Article" set title='hacked' where id=1$$)),

 ('3.4 platform super-admin edits an article',         'ALLOW',
  pg_temp.attempt(:SUPERAD,'admin',
   $$update "Article" set title='edited' where id=1$$))
) t(test, expected, actual);
rollback;
