/// Centralized API endpoint paths
/// Update these constants in one place to propagate across the app.
class Endpoints {
  static const String signIn = '/auth/sign-in';
  static const String refresh = '/auth/refresh';
  static const String signOut = '/auth/sign-out';

  static const String churches = '/church';
  static String church({required int churchId}) => '/church/$churchId';

  // Location
  static String location({required int locationId}) => '/location/$locationId';

  // Column
  static String column({required int columnId}) => '/column/$columnId';
  static const String columns = '/column';

  // Account (Members)
  static const String accounts = '/account';
  static const String accountCount = '/account/count';
  static String account(int accountId) => '/account/$accountId';

  // Activities
  static const String activities = '/activity';
  static String activity(String activityId) => '/activity/$activityId';

  // Revenue
  static const String revenues = '/revenue';
  static String revenue(String revenueId) => '/revenue/$revenueId';

  // Expense
  static const String expenses = '/expense';
  static String expense(String expenseId) => '/expense/$expenseId';

  // Report
  static const String reports = '/report';
  static String report(String reportId) => '/report/$reportId';

  // Document
  static const String documents = '/document';
  static String document(String documentId) => '/document/$documentId';

  //Approval Rule
  static const String approvalRules = '/approval-rule';
  static String approvalRule(String approvalRuleId) =>
      '/approval-rule/$approvalRuleId';

  // Approver
  static const String approvers = '/approver';
  static String approver(int approverId) => '/approver/$approverId';

  // Church sub-resources (columns and positions)
  static String churchColumns(String churchId) => '/church/$churchId/columns';
  static String churchColumn(String churchId, String columnId) =>
      '/church/$churchId/columns/$columnId';
  static String churchPositions(String churchId) =>
      '/church/$churchId/positions';
  static String churchPosition(String churchId, String positionId) =>
      '/church/$churchId/positions/$positionId';

  // Membership positions root (query by churchId)
  static const String membershipPositions = '/membership-position';
  static String membershipPosition({required int positionId}) =>
      '/membership-position/$positionId';

  static const String memberships = '/membership';
  static String membership({required int membershipId}) =>
      '/membership/$membershipId';

  static const String validatePhone = '/auth/validate';

  // Song
  static const String songs = '/song';
  static String song(String songId) => '/song/$songId';

  // Financial Account Number
  static const String financialAccountNumbers = '/financial-account-number';
  static const String availableFinancialAccountNumbers =
      '/financial-account-number/available';
  static String financialAccountNumber(String id) =>
      '/financial-account-number/$id';
}
