import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tanggal.dart';
import 'clock.dart';

/// Today and now in WITA at launch, read once (README 3.3). The anchor does
/// not move if the app runs past midnight.
final launchProvider = Provider<({Tanggal anchor, DateTime now})>((ref) {
  final now = ref.read(clockProvider).now();
  return (anchor: Tanggal.dari(now), now: now);
});
