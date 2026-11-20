import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped by every successful command and every repository timer that
/// changes state (README 3.3). Read models watch it.
class StoreRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final revisionProvider = NotifierProvider<StoreRevision, int>(
  StoreRevision.new,
);
