/// Utility class for building Pusher Beams device interest names.
///
/// This class provides static methods to format interest names that match
/// the backend patterns for push notification targeting.
class InterestBuilder {
  InterestBuilder._();

  /// Global interest for all app users
  static const String globalInterest = 'palakat';

  /// Global debug interest for all app users
  static const String globalInterestDebug = 'debug-palakat';

  /// Format church-wide interest
  /// Pattern: church.{churchId}
  static String church(int churchId) => 'church.$churchId';

  /// Format BIPRA division interest within a church
  /// Pattern: church.{churchId}_bipra.{BIPRA}
  /// BIPRA is converted to uppercase
  static String churchBipra(int churchId, String bipra) =>
      'church.${churchId}_bipra.${bipra.toUpperCase()}';

  /// Format column/group interest within a church
  /// Pattern: church.{churchId}_column.{columnId}
  static String churchColumn(int churchId, int columnId) =>
      'church.${churchId}_column.$columnId';

  /// Format BIPRA within a specific column
  /// Pattern: church.{churchId}_column.{columnId}_bipra.{BIPRA}
  /// BIPRA is converted to uppercase
  static String churchColumnBipra(int churchId, int columnId, String bipra) =>
      'church.${churchId}_column.${columnId}_bipra.${bipra.toUpperCase()}';

  /// Format individual membership interest
  /// Pattern: membership.{membershipId}
  static String membership(int membershipId) => 'membership.$membershipId';

  static String membershipBirthday(int membershipId) =>
      'membership.$membershipId.birthday';

  /// Format individual account interest
  /// Pattern: account.{accountId}
  static String account(int accountId) => 'account.$accountId';

  /// Build all applicable interests for a user based on their membership data
  ///
  /// Returns a list of interests including:
  /// - Global interest (palakat)
  /// - Church interest
  /// - Church BIPRA interest
  /// - Account interest
  /// - Membership interest
  /// - Column interest (if columnId provided)
  /// - Column BIPRA interest (if columnId provided)
  static List<String> buildUserInterests({
    required int membershipId,
    required int churchId,
    required String bipra,
    required int accountId,
    int? columnId,
  }) {
    final interests = <String>[
      globalInterest,
      globalInterestDebug,
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
