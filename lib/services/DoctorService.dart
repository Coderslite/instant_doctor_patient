import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/services/BaseService.dart';

import '../main.dart';
import '../models/UserModel.dart';

class DoctorService extends BaseService {
  var userCol = db.collection("Users");

  Stream<UserModel> getDoc({required String docId}) {
    var result = userCol
        .doc(docId)
        .snapshots()
        .map((event) => UserModel.fromJson(event.data()!));
    return result;
  }

  Stream<List<UserModel>> getAllDocs() {
    var result = userCol
        .where('role', isEqualTo: 'Doctor')
        // .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => UserModel.fromJson(e.data())).toList());
    return result;
  }

  Stream<List<UserModel>> getTopDocs() {
    var result = userCol
        .where('role', isEqualTo: 'Doctor')
        .where('isAvailable', isEqualTo: true)
        .limit(4)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => UserModel.fromJson(e.data())).toList());
    return result;
  }

  Future<String?> getAvailableDoctor() async {
    try {
      // Calculate timestamp for 24 hours ago
      final twentyFourHoursAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(hours: 24)),
      );

      // Get all active doctors (last seen in last 24 hours and not away)
      final activeDoctorsQuery = await userCol
          .where('role', isEqualTo: 'Doctor')
          .where('isAvailable', isEqualTo: true)
          .where('lastSeen', isGreaterThanOrEqualTo: twentyFourHoursAgo)
          .where('status', isNotEqualTo: 'away')
          .get();

      if (activeDoctorsQuery.docs.isEmpty) {
        return null; // No active doctors found
      }

      // Convert to UserModel list
      final activeDoctors = activeDoctorsQuery.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      // Create a map to store doctor IDs and their active appointment counts
      final Map<String, int> doctorAppointmentCounts = {};

      // Check each doctor's active appointments
      for (final doctor in activeDoctors) {
        // Get completed appointments in the last 24 hours
        final appointmentsQuery = await db
            .collection('Appointments')
            .where('doctorId', isEqualTo: doctor.id)
            .where('status', isEqualTo: 'completed')
            .where('updatedAt', isGreaterThanOrEqualTo: twentyFourHoursAgo)
            .get();

        doctorAppointmentCounts[doctor.id!] = appointmentsQuery.docs.length;
      }

      // Sort doctors by appointment count (ascending)
      final sortedDoctors = doctorAppointmentCounts.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      // Return the doctor with the least appointments (first in the sorted list)
      return sortedDoctors.isNotEmpty ? sortedDoctors.first.key : null;
    } catch (e) {
      print('Error finding available doctor: $e');
      return null;
    }
  }
}
