// Canonical Prisma `include` shape for a finance entry (revenue or expense).
// Kind-independent: the relation shape is identical for both. Sourced here by
// FinanceEntryService and FinanceService so the include never drifts between
// copies (previously three copies, one of which silently omitted `cashAccount`).
export const financeEntryInclude = {
  approvers: {
    include: {
      membership: {
        include: {
          account: {
            select: {
              id: true,
              name: true,
              phone: true,
              dob: true,
            },
          },
          membershipPositions: true,
        },
      },
    },
  },
  activity: {
    include: {
      approvers: {
        include: {
          membership: {
            include: {
              account: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  dob: true,
                },
              },
              membershipPositions: true,
            },
          },
        },
      },
      supervisor: {
        include: {
          account: {
            select: {
              id: true,
              name: true,
              phone: true,
              dob: true,
            },
          },
          membershipPositions: true,
        },
      },
      location: true,
    },
  },
  financialAccountNumber: true,
  cashAccount: true,
} as const;
