import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class DataController {
  final _db = FirebaseFirestore.instance;

  Future<void> deleteGroup(String groupID) {
    return _db
        .collection('group_list')
        .doc(groupID)
        .delete()
        .onError((error, stackTrace) => Logger().e(error));
  }
}
