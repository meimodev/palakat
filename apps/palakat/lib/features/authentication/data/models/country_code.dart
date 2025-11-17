/// Model representing a country code for phone number input
class CountryCode {
  /// Country code with + prefix (e.g., "+62")
  final String code;

  /// Country name (e.g., "Indonesia")
  final String name;

  /// Country flag emoji (e.g., "🇮🇩")
  final String flag;

  /// Dial code without + prefix (e.g., "62")
  final String dialCode;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
    required this.dialCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          dialCode == other.dialCode;

  @override
  int get hashCode => code.hashCode ^ dialCode.hashCode;

  @override
  String toString() => '$flag $name ($code)';
}

/// List of supported country codes for phone authentication
const List<CountryCode> supportedCountryCodes = [
  CountryCode(code: '+62', name: 'Indonesia', flag: '🇮🇩', dialCode: '62'),
  CountryCode(code: '+60', name: 'Malaysia', flag: '🇲🇾', dialCode: '60'),
  CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬', dialCode: '65'),
  CountryCode(code: '+63', name: 'Philippines', flag: '🇵🇭', dialCode: '63'),
];
