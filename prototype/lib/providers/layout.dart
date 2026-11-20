import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/tata.dart';

/// The layout, chosen once at launch (README 3.2). Flow tests override it.
final layoutProvider = Provider<Tata>((ref) => tataPerangkat());
