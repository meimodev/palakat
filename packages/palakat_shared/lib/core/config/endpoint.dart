/// Centralized API endpoint paths
/// Update these constants in one place to propagate across the app.
class Endpoints {
  static const String signIn = '/auth/sign-in';
  static const String superAdminSignIn = '/auth/super-admin/sign-in';
  static const String refresh = '/auth/refresh';
  static const String signOut = '/auth/sign-out';
  static const String syncClaims = '/auth/sync-claims';

  static const String articles = '/articles';
  static String article(int articleId) => '/articles/$articleId';
  static String articleLike(int articleId) => '/articles/$articleId/like';

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

  // Finance
  static const String finance = '/finance';
  static const String financeOverview = '/finance/overview';

  static const String cashAccounts = '/cash-account';
  static String cashAccount(String cashAccountId) =>
      '/cash-account/$cashAccountId';
  static const String cashMutations = '/cash-mutation';
  static String cashMutation(String cashMutationId) =>
      '/cash-mutation/$cashMutationId';
  static const String cashTransfer = '/cash-mutation/transfer';

  // Report
  static const String reports = '/report';
  static String report(String reportId) => '/report/$reportId';
  static const String generateReport = '/report/generate';

  // Church Letterhead
  static const String churchLetterheadMe = '/church-letterhead/me';
  static const String churchLetterheadMeLogo = '/church-letterhead/me/logo';

  // Document
  static const String documents = '/document';
  static String document(String documentId) => '/document/$documentId';

  // File Manager
  static const String fileManager = '/file-manager';
  static const String fileFinalize = '/file-manager/finalize';
  static String fileManagerResolveDownloadUrl(String fileId) =>
      '/file-manager/$fileId/resolve-download-url';
  static String fileManagerProxy(String fileId) =>
      '/file-manager/$fileId/proxy';

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
  static const String songs = '/public/songs';
  static String song(String songId) => '/public/songs/$songId';

  // Song (Admin)
  static const String adminSongs = '/admin/songs';
  static String adminSong(String songId) => '/admin/songs/$songId';

  static const String adminSongParts = '/admin/song-parts';
  static String adminSongPart(String songPartId) =>
      '/admin/song-parts/$songPartId';

  // Financial Account Number
  static const String financialAccountNumbers = '/financial-account-number';
  static const String availableFinancialAccountNumbers =
      '/financial-account-number/available';
  static String financialAccountNumber(String id) =>
      '/financial-account-number/$id';
}
