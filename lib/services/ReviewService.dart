import 'package:instant_doctor/models/ReviewsModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../function/send_notification.dart';
import '../main.dart';
import 'BaseService.dart';

class ReviewService extends BaseService {
  var reviewCol = db.collection("Reviews");

  Future<ReviewsModel?> getAppointmentReview(
      {required String docId, required String appointmentId}) async {
    var reviewRef = await reviewCol
        .where('doctorId', isEqualTo: docId)
        .where('appointmentId', isEqualTo: appointmentId)
        .get();
    if (reviewRef.docs.isNotEmpty) {
      var reviewData = reviewRef.docs.first.data();
      return ReviewsModel.fromJson(reviewData);
    } else {
      return null;
    }
  }

  Stream<List<ReviewsModel>> getDoctorReviews({required String docId}) {
    var reviewRef = reviewCol.where('doctorId', isEqualTo: docId).snapshots();
    return reviewRef.map((event) =>
        event.docs.map((e) => ReviewsModel.fromJson(e.data())).toList());
  }

  Future<void> addReview({required ReviewsModel review}) async {
    var res = await reviewCol.add(review.toJson());
    await updateReview(id: res.id, data: {"id": res.id.validate()});
    var token =
        await userService.getUserToken(userId: review.doctorId.validate());
    sendNotification([token], "Appointment Review",
        "You got ${review.rating} star rating", '', '');
  }

  Future<void> updateReview(
      {required String id, required Map<String, dynamic> data}) async {
    await reviewCol.doc(id).update(data);
  }

  Future<void> deleteReview({required String id}) async {
    await reviewCol.doc(id).delete();
  }
}
