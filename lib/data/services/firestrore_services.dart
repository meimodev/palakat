import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palakat/shared/utils.dart';
import 'dart:developer' as dev;

class FirestoreService {
  FirebaseFirestore firestore;

  FirestoreService() : firestore = FirebaseFirestore.instance;

  // ignore: unused_field
  final String _keyCollectionApp = 'app';

  // ignore: unused_field
  final String _keyCollectionChurches = 'churches';

  // ignore: unused_field
  final String _keyCollectionEvents = 'events';

  // ignore: unused_field
  final String _keyCollectionMembership = 'membership';

  // ignore: unused_field
  final String _keyCollectionUsers = 'users';

  dynamic firestoreLogger(
    dynamic Function() request,
    String? operation,
  ) async {
    operation = operation ?? 'logging';
    try {
      final res = request();
      dev.log('[FIRESTORE] $operation SUCCESS');
      return res;
    } catch (e) {
      dev.log('[FIRESTORE] $operation ERROR');
      dev.log(e.toString());
      return null;
    }
  }

  Future<Object?> getUser({required String phoneOrId}) async {
    final isPhoneNumber =
        phoneOrId.startsWith("08") || phoneOrId.startsWith("+62");
    final col = firestore.collection(_keyCollectionUsers);

    if (isPhoneNumber) {
      final phone = phoneOrId.cleanPhone(useCountryCode: true);
      QuerySnapshot<Map<String, dynamic>>? docs = await firestoreLogger(
        col.where("phone", isEqualTo: phone).limit(1).get,
        'getUser(phone)',
      );
      if (docs == null || docs.docs.isEmpty) {
        return null;
      }
      return docs.docs.first.data();
    }

    final id = phoneOrId;
    DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
      col.doc(id).get,
      'getUser(user_id)',
    );
    return doc!.data();
  }

  Future<Object?> getMembership({required String id}) async {
    final col = firestore.collection(_keyCollectionMembership);
    DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
      col.doc(id).get,
      'getMembership',
    );
    return doc!.data();
  }

  Future<Object?> getChurch({required String id}) async {
    final col = firestore.collection(_keyCollectionChurches);
    DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreLogger(
      col.doc(id).get,
      'getChurch',
    );
    return doc!.data();
  }

  Future<List<Object?>> getEvents({
    required String churchId,
    DateTime? from,
    DateTime? to,
  }) async {
    final col = firestore.collection(_keyCollectionEvents);
    Query? query;
    String log = "church_id: $churchId";

    if (from != null) {
      query = col
          .where('church_id', isEqualTo: churchId)
          .where('event_date_time_stamp', isGreaterThanOrEqualTo: from)
          .where('event_date_time_stamp', isLessThanOrEqualTo: to);
      log = "$log from: ${from.toString()} to: ${to.toString()}";
    }

    query ??= col.where('church_id', isEqualTo: churchId);

    QuerySnapshot<Map<String, dynamic>>? docs = await firestoreLogger(
      query.get,
      'getEvents $log',
    );

    if (docs == null) {
      return [];
    }

    final res = docs.docs.map((e) => e.data()).toList();
    return res;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final users = firestore.collection(_keyCollectionUsers);
    await firestoreLogger(
      () => users.doc(data['id']).set(
            data,
            SetOptions(merge: true),
          ),
      'updateUser',
    );
  }

  Future<Object?> setUser(Map<String, dynamic> data) async {
    final users = firestore.collection(_keyCollectionUsers);

    final userId = await firestoreLogger(
      () async {
        final doc = await users.add(data);
        return doc.id;
      },
      'setUser',
    );

    await firestoreLogger(
      () => users.doc(userId).set(
        {"id": userId},
        SetOptions(merge: true),
      ),
      'setUser update id',
    );

    return {
      ...data,
      "id": userId,
    };
  }

  Future<List<Object?>> readChurches() async {
    final col = firestore.collection(_keyCollectionChurches);

    QuerySnapshot<Map<String, dynamic>>? docs = await firestoreLogger(
      col.get,
      'readChurches()',
    );
    if (docs == null) {
      return [];
    }
    final res = docs.docs.map((e) => e.data()).toList();
    return res;
  }

  Future<Object?> setMembership(
      Map<String, dynamic> data, String userId) async {
    final memberships = firestore.collection(_keyCollectionMembership);
    final users = firestore.collection(_keyCollectionUsers);

    final membershipId = await firestoreLogger(
      () async {
        final doc = await memberships.add(data);
        return doc.id;
      },
      'setMembership()',
    );

    await firestoreLogger(
      () => memberships.doc(membershipId).set(
        {"id": membershipId},
        SetOptions(merge: true),
      ),
      'setMembership() update id',
    );

    await firestoreLogger(
      () => users.doc(userId).set(
        {"membership_id": membershipId},
        SetOptions(merge: true),
      ),
      'setMembership() update membership id in user',
    );

    return {
      ...data,
      "id": membershipId,
    };
  }

  Future<void> updateMembership(Map<String, dynamic> data) async {
    final col = firestore.collection((_keyCollectionMembership));
    await firestoreLogger(
      () => col.doc(data['id']).set(data, SetOptions(merge: true)),
      'updateMembership',
    );
  }
}
