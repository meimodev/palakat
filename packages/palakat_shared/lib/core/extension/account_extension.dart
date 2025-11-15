import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/account.dart';

/// Data class to hold age information in years, months, and days
class AgeInfo {
  final int years;
  final int months;
  final int days;

  const AgeInfo({
    required this.years,
    required this.months,
    required this.days,
  });

  /// Format age as "X yr, Y mo, Z d"
  String get formatted {
    return '${years}y ${months}m ${days}d';
  }
}

extension AccountExtension on Account {
  /// Calculates the BIPRA (church group) category based on age, gender, and marital status
  /// 
  /// Rules:
  /// - ASM (Kids): Age 0-12
  /// - RMJ (Teens): Age 13-17
  /// - PMD (Youths): Age 18-35 and unmarried
  /// - PKB (Fathers): Male, age 18+ and married
  /// - WKI (Mothers): Female, age 18+ and married
  /// - ELD (Elders): Default fallback for others (36+)
  Bipra get calculateBipra {
    final now = DateTime.now();
    final age = now.year - dob.year - 
        ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1);
    
    // Kids: 0-12 years old
    if (age <= 12) {
      return Bipra.kids;
    }
    
    // Teens: 13-17 years old
    if (age >= 13 && age <= 17) {
      return Bipra.teens;
    }
    
    // For 18+ years old
    if (age >= 18) {
      // Married individuals
      if (maritalStatus == MaritalStatus.married) {
        return gender == Gender.male ? Bipra.fathers : Bipra.mothers;
      }
      
      // Unmarried individuals 18-35
      if (age <= 35) {
        return Bipra.youths;
      }
    }
    
    // Default fallback for edge cases (e.g., 36+ and unmarried)
    return Bipra.elder;
  }

  /// Calculates the current age in years, months, and days
  AgeInfo get calculateAge {
    final now = DateTime.now();
    
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    int days = now.day - dob.day;
    
    // Adjust if days are negative
    if (days < 0) {
      months--;
      // Get days in previous month
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }
    
    // Adjust if months are negative
    if (months < 0) {
      years--;
      months += 12;
    }
    
    return AgeInfo(years: years, months: months, days: days);
  }
}
