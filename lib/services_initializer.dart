// initial_bindings.dart

import 'package:get/get.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/ConnectivityController.dart';
import 'package:instant_doctor/controllers/MedicationController.dart';
import 'package:instant_doctor/controllers/NotificationController.dart';
import 'package:instant_doctor/controllers/OrderController.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/controllers/ReferController.dart';
import 'package:instant_doctor/controllers/ReportController.dart';
import 'package:instant_doctor/controllers/ZegocloudController.dart';
import 'package:instant_doctor/controllers/LocationController.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:instant_doctor/services/DrugService.dart';
import 'package:instant_doctor/services/HealthTipService.dart';
import 'package:instant_doctor/services/LabResultService.dart';
import 'package:instant_doctor/services/LocationService.dart';
import 'package:instant_doctor/services/NotificationService.dart';
import 'package:instant_doctor/services/OrderService.dart';
import 'package:instant_doctor/services/PharmacyService.dart';
import 'package:instant_doctor/services/ReferralService.dart';
import 'package:instant_doctor/services/ReportService.dart';
import 'package:instant_doctor/services/ReviewService.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:instant_doctor/services/AuthenticationService.dart';
import 'package:instant_doctor/services/MedicationService.dart';
import 'package:instant_doctor/services/PresciptionService.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:instant_doctor/controllers/ChatController.dart';
import 'package:instant_doctor/controllers/LapResultController.dart';
import 'package:instant_doctor/controllers/UploadFileController.dart';
import 'package:instant_doctor/controllers/UserController.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Controllers
    Get.lazyPut(() => ZegoCloudController());
    Get.lazyPut(() => PaymentController());
    Get.lazyPut(() => OrderController());
    Get.lazyPut(() => BookingController());
    Get.lazyPut(() => LocationController());
    Get.lazyPut(() => UserController());
    Get.lazyPut(() => AuthenticationController());
    Get.lazyPut(() => LabResultController());
    Get.lazyPut(() => ReferralController());
    Get.lazyPut(() => UploadFileController());
    Get.lazyPut(() => ReportController());
    Get.lazyPut(() => MedicationController());
    Get.lazyPut(() => NotificationController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ConnectivityController());

    // Services
    Get.lazyPut(() => WalletService());
    Get.lazyPut(() => UserService());
    Get.lazyPut(() => NotificationService());
    Get.lazyPut(() => TransactionService());
    Get.lazyPut(() => AppointmentService());
    Get.lazyPut(() => MedicationService());
    Get.lazyPut(() => DoctorService());
    Get.lazyPut(() => PharmacyService());
    Get.lazyPut(() => LabResultService());
    Get.lazyPut(() => DrugService());
    Get.lazyPut(() => ReferralService());
    Get.lazyPut(() => HealthTipService());
    Get.lazyPut(() => ReviewService());
    Get.lazyPut(() => ReportService());
    Get.lazyPut(() => PresciptionService());
    Get.lazyPut(() => LocationService());
    Get.lazyPut(() => OrderService());
    Get.lazyPut(() => AuthenticationService());
  }
}
