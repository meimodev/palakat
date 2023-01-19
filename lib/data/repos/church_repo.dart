import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/services/firestrore_services.dart';

abstract class ChurchRepoContract {}

class ChurchRepo implements ChurchRepoContract {
  final firestore = FirestoreService();

  Future<List<Church>> readRegisteredChurches() async {
    final res = await firestore.readChurches();
    final data =
        res.map((e) => Church.fromMap(e as Map<String, dynamic>)).toList();
    return data;
  }
}
