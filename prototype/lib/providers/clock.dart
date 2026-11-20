import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';

/// The real WITA clock; flow tests override it with a [FixedClock].
final clockProvider = Provider<Clock>((ref) => const SystemClock());
