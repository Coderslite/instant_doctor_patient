import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/LocationService.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:nb_utils/nb_utils.dart';
import '../constant/constants.dart';
import '../models/DrugModel.dart';
import '../models/OrderModel.dart';
import '../models/PharmacyModel.dart';
import '../screens/home/Root.dart';
import '../services/GetUserId.dart';
import '../services/OrderService.dart';
import 'PaymentController.dart';

class OrderController extends GetxController {
  var cart = <DrugModel>[].obs;
  RxInt deliveryFee = 0.obs;
  RxBool isCalculating = false.obs;
  RxBool isLoading = false.obs;
  List<OrderModel> orders = [];

  final locationService = Get.find<LocationService>();
  final userService = Get.find<UserService>();
  // Save cart to SharedPreferences
  Future<void> handleAddToCart({required DrugModel drug}) async {
    // Check if the drug is already in the cart
    bool exists = cart.any((item) => item.id == drug.id);

    if (!exists) {
      // Add quantity = 1 before adding to cart
      DrugModel drugWithQty = drug.copyWith(quantity: 1);

      cart.add(drugWithQty);

      // Save to shared preferences
      var prefs = await SharedPreferences.getInstance();
      List<String> cartItems =
          cart.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('cart', cartItems);

      print("Drug added to cart with quantity 1.");
    } else {
      print("Drug is already in the cart.");
    }
  }

  // Retrieve saved cart from SharedPreferences
  Future<void> handleGetSavedCarts() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? cartItems = prefs.getStringList('cart');

    if (cartItems != null) {
      cart.value = cartItems
          .map((item) => DrugModel.fromJson(jsonDecode(item)))
          .toList();
    }
  }

  // Remove a specific item from the cart
  Future<void> handleRemoveFromCart({required DrugModel drug}) async {
    cart.removeWhere((item) => item.id == drug.id); // Assuming 'id' is unique

    var prefs = await SharedPreferences.getInstance();
    List<String> cartItems =
        cart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', cartItems);
  }

  // Clear the entire cart
  Future<void> handleClearCart() async {
    cart.clear();

    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }

  double get subtotal => cart.fold(0,
      (sum, item) => sum + (item.amount.validate() * item.quantity.validate()));

  // Update quantity in the cart
  void increaseQuantity(DrugModel drug) {
    int index = cart.indexWhere((item) => item.id == drug.id);
    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    }
  }

  void decreaseQuantity(DrugModel drug) {
    int index = cart.indexWhere((item) => item.id == drug.id);
    if (index != -1 && cart[index].quantity.validate() > 1) {
      cart[index].quantity--;
      cart.refresh();
    }
  }

  double calculateDistance(GeoPoint start, GeoPoint end) {
    const earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLon = _degreesToRadians(end.longitude - start.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  // Helper function to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Function to get delivery price based on user's location and pharmacy's location
  Future<int> getDeliveryPrice(GeoPoint userLocation, DrugModel drug) async {
    var pharmacySnapshot = await FirebaseFirestore.instance
        .collection('Pharmacies')
        .doc(drug.pharmacyId)
        .get();

    if (!pharmacySnapshot.exists) {
      throw Exception("Pharmacy not found");
    }

    PharmacyModel pharmacy = PharmacyModel.fromJson(pharmacySnapshot.data()!);

    // Calculate distance between user and pharmacy
    double distanceInKm = calculateDistance(userLocation, pharmacy.location!);

    // Round down the distance to the nearest integer
    int roundedDistance = distanceInKm.floor() < 1 ? 1 : distanceInKm.floor();

    // Calculate the delivery price
    int deliveryPrice = roundedDistance * pharmacy.deliveryCharge!;

    return deliveryPrice;
  }

  Future<double> getTotalDeliveryFee() async {
    try {
      double totalDeliveryFee = 0.0;
      isCalculating.value = true;

      // Track processed pharmacies to avoid duplicate delivery charges
      Set<String> processedPharmacies = {};

      for (var drug in cart) {
        if (!processedPharmacies.contains(drug.pharmacyId)) {
          // Calculate delivery fee if this pharmacy hasn't been processed
          int deliveryPrice = await getDeliveryPrice(
            GeoPoint(locationController.latitude.value,
                locationController.longitude.value),
            drug,
          );

          totalDeliveryFee += deliveryPrice;
          processedPharmacies
              .add(drug.pharmacyId!); // Mark pharmacy as processed
        }
      }
      deliveryFee.value = totalDeliveryFee.toInt();
      return totalDeliveryFee;
    } finally {
      isCalculating.value = false;
    }
  }

  Future<void> makeOrder() async {
    try {
      isLoading.value = true;
      orders.clear(); // Important to prevent multiple submissions

      // Group cart items by pharmacy
      Map<String, List<DrugModel>> pharmacyOrders = {};
      for (var drug in cart) {
        if (!pharmacyOrders.containsKey(drug.pharmacyId)) {
          pharmacyOrders[drug.pharmacyId!] = [];
        }
        pharmacyOrders[drug.pharmacyId!]!.add(drug);
      }

      // Retrieve user profile
      var user =
          await userService.getProfileById(userId: userController.userId.value);

      var email = user.email;

      for (var entry in pharmacyOrders.entries) {
        String pharmacyId = entry.key;
        List<DrugModel> items = entry.value;

        // Calculate delivery fee for this pharmacy only
        int deliveryPrice = await getDeliveryPrice(
          GeoPoint(locationController.latitude.value,
              locationController.longitude.value),
          items.first,
        );

        int totalAmount = items.fold(0,
                (sum1, drug) => sum1 + (drug.amount!.toInt() * drug.quantity)) +
            deliveryPrice;

        final orderService = Get.find<OrderService>();
        String trackingId = await orderService.generateUniqueTrackingId();

        orders.add(OrderModel(
          userId: userController.userId.value,
          pharmacyId: pharmacyId,
          items: items.map((item) => item.toJson()).toList(),
          totalAmount: totalAmount,
          status: "pending",
          address: locationController.address.value,
          deliveryFee: deliveryPrice,
          trackingId: trackingId,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ));
      }

      // Payment only for the overall total
      int grandTotal = orders.fold(0, (sum, order) => sum + order.totalAmount!);

      final paymentController = Get.find<PaymentController>();
      paymentController.makePayment(
        email: email!,
        context: Get.context!,
        amount: grandTotal,
        paymentFor: PaymentFor.order,
      );
    } catch (e) {
      errorSnackBar(title: "Failed to make orders: $e");
      isLoading.value = false;
    }
  }

  orderNow({required int pharmacyEarning}) async {
    try {
      final orderService = Get.find<OrderService>();

      for (var order in orders) {
        order.pharmacyEarning = pharmacyEarning;
        await orderService.newOrder(order: order);
        for (var item in order.items.validate()) {
          orderService.updateQuantity(
              itemId: item['id'], qty: item['quantity']);
        }
      }

      await handleClearCart();
      successSnackBar(title: "Orders placed successfully.");
      settingsController.selectedIndex.value = 2;
      Root().launch(Get.context!);
      isLoading.value = false;
    } catch (err) {
      print(err);
    } finally {
      isLoading.value = false;
    }
  }

  updateItemQuantity({required String itemId}) async {}
}
