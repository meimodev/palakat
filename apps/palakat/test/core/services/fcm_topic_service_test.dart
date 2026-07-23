import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/core/services/fcm_topic_service.dart';

void main() {
  group('FcmTopicService', () {
    test('subscribes to every topic in order', () async {
      final subscribed = <String>[];
      final service = FcmTopicService(
        subscribeTopic: (t) async => subscribed.add(t),
        unsubscribeTopic: (t) async {},
      );

      await service.subscribe(['church.1', 'membership.7', 'account.9']);

      expect(subscribed, ['church.1', 'membership.7', 'account.9']);
    });

    test('one failing topic does not drop the rest (error isolation)', () async {
      final subscribed = <String>[];
      final service = FcmTopicService(
        subscribeTopic: (t) async {
          if (t == 'church.1') throw Exception('boom');
          subscribed.add(t);
        },
        unsubscribeTopic: (t) async {},
      );

      await service.subscribe(['church.1', 'membership.7', 'account.9']);

      // church.1 threw, but the remaining topics were still attempted.
      expect(subscribed, ['membership.7', 'account.9']);
    });

    test('unsubscribes from every topic, isolating failures', () async {
      final removed = <String>[];
      final service = FcmTopicService(
        subscribeTopic: (t) async {},
        unsubscribeTopic: (t) async {
          if (t == 'membership.7') throw Exception('boom');
          removed.add(t);
        },
      );

      await service.unsubscribe(['church.1', 'membership.7', 'account.9']);

      expect(removed, ['church.1', 'account.9']);
    });
  });
}
