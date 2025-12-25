/// Utility class for building Pusher Beams device interest names.
///
/// Interest patterns follow the backend conventions:
/// - `palakat` - Global interest for all app users
/// - `church.{churchId}` - Church-wide notifications
/// - `church.{churchId}_bipra.{BIPRA}` - BIPRA division within a church
/// - `church.{churchId}_column.{columnId}` - Column/group within a church
/// - `church.{churchId}_column.{columnId}_bipra.{BIPRA}` - BIPRA within a column
/// - `membership.{membershipId}` - Individual membership notifications
///
/// **Validates: Requirements 4.2**
class InterestBuilder {
  /// Global interest for all app users
  static const String globalInterest = 'palakat';

  /// Formats a church-wide interest name.
  ///
  /// @param churchId - The church ID
  /// @returns Formatted interest name: church.{churchId}
  static String church(int churchId) => 'church.$churchId';

  /// Formats a BIPRA group interest name.
  ///
  /// @param churchId - The church ID
  /// @param bipra - The BIPRA division (PKB, WKI, PMD, RMJ, ASM)
  /// @returns Formatted interest name: church.{churchId}_bipra.{BIPRA}
  static String churchBipra(int churchId, String bipra) =>
      'church.${churchId}_bipra.${bipra.toUpperCase()}';

  /// Formats a column interest name.
  ///
  /// @param churchId - The church ID
  /// @param columnId - The column ID
  /// @returns Formatted interest name: church.{churchId}_column.{columnId}
  static String churchColumn(int churchId, int columnId) =>
      'church.${churchId}_column.$columnId';

  /// Formats a column BIPRA interest name.
  ///
  /// @param churchId - The church ID
  /// @param columnId - The column ID
  /// @param bipra - The BIPRA division
  /// @returns Formatted interest name: church.{churchId}_column.{columnId}_bipra.{BIPRA}
  static String churchColumnBipra(int churchId, int columnId, String bipra) =>
      'church.${churchId}_column.${columnId}_bipra.${bipra.toUpperCase()}';

  /// Formats a membership interest name for individual notifications.
  ///
  /// @param membershipId - The membership ID
  /// @returns Formatted interest name: membership.{membershipId}
  static String membership(int membershipId) => 'membership.$membershipId';

  /// Formats an account interest name for individual notifications.
  ///
  /// @param accountId - The account ID
  /// @returns Formatted interest name: account.{accountId}
  static String account(int accountId) => 'account.$accountId';

  /// Builds a list of all applicable interests for a user.
  ///
  /// @param membershipId - The user's membership ID
  /// @param churchId - The user's church ID
  /// @param bipra - The user's BIPRA division abbreviation
  /// @param accountId - The user's account ID
  /// @param columnId - Optional column ID if user belongs to a column
  /// @returns List of all interest names the user should subscribe to
  static List<String> buildUserInterests({
    required int membershipId,
    required int churchId,
    required String bipra,
    required int accountId,
    int? columnId,
  }) {
    final interests = <String>[
      globalInterest,
      church(churchId),
      churchBipra(churchId, 'GENERAL'),
      churchBipra(churchId, bipra),
      account(accountId),
      membership(membershipId),
    ];

    if (columnId != null) {
      interests.add(churchColumn(churchId, columnId));
      interests.add(churchColumnBipra(churchId, columnId, bipra));
    }

    return interests;
  }
}
