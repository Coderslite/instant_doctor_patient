import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';

abstract class BaseService {
  late CollectionReference ref;

  Future<DocumentReference> addDocument(Map<String, dynamic> data) async {
    var doc = await ref.add(data);
    doc.update({'id': doc.id});
    return doc;
  }

  Future<void> addDocumentWithCustomId(String? id, Map<String, dynamic> data) async {
    await ref.doc(id).set(data);
  }

  Future<DocumentReference> addDocumentWithCustomIds(String id, Map<String, dynamic> data) async {
    var doc = ref.doc(id);

    return await doc.set(data).then((value) {
      return doc;
    }).catchError((e) {
      log(e);
      throw e;
    });
  }

  Future<void> updateDocument(Map<String, dynamic> data, String? id) async {
    await ref.doc(id).update(data);
  }

  Future<void> removeDocument(String? id) async {
    await ref.doc(id).delete();
  }
}
