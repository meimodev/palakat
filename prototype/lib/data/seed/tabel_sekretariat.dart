import '../../domain/secretariat/secretariat.dart';

/// The Secretariat tables (README 5.7), owned by M7: church documents,
/// announcements, Warta editions and letter requests.
class TabelSekretariat {
  /// Oldest first.
  final List<ChurchDocument> documents = [];
  final List<Announcement> announcements = [];
  final List<WartaEdition> editions = [];
  final List<LetterRequest> letters = [];

  /// The last outgoing-letter number given per year (README 5.5).
  final Map<int, int> letterCounters = {};

  // ponytail: the household line and Kolom of the members the Secretariat
  // reads, kept here until M10 joins MemberRepository (letters from member
  // records, J2).
  final Map<String, String> households = {};
  final Map<String, String> memberScopes = {};
}
