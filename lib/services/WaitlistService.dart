import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/WaillistModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';

class WaitlistService {
  var waitlistCol = db.collection("Waitlist");

  Future<void> newWaitlist(WaitlistModel waitlist) async {
    var res = await waitlistCol.add(waitlist.toJson());
    await updateWaitlist(res.id, {"id": res.id});
  }

  Future<void> updateWaitlist(String id, Map<String, dynamic> data) async {
    await waitlistCol.doc(id).update(data);
  }

  Future<bool> checkNotified() async {
    var res = await waitlistCol
        .where('userId', isEqualTo: userController.userId.value)
        .where(
          'location',
          isEqualTo: GeoPoint(locationController.latitude.value,
              locationController.longitude.value),
        )
        .get();
    return res.docs.isNotEmpty;
  }

  
}
