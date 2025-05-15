import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/DrugModel.dart';

class DrugService {
  var drugCol = db.collection("Drugs");
  var drugCatCol = db.collection("DrugCategories");

  Stream<List<DrugModel>> getDrugs() {
    var ref = drugCol.snapshots();
    return ref.map((event) =>
        event.docs.map((e) => DrugModel.fromJson(e.data())).toList());
  }

 Stream<List<DrugCategoryModel>> getDrugCat() {
    var ref =drugCatCol.snapshots();
    return ref.map((event)=>event.docs.map((e) => DrugCategoryModel.fromJson(e.data())).toList());
  }

  Future<DrugModel> getDrug({required String id}) async {
    var ref = await drugCol.doc(id).get();
    return DrugModel.fromJson(ref.data()!);
  }
}
