import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';
import 'package:instant_doctor/screens/drug/Cart.dart';
import 'package:instant_doctor/screens/drug/MedicineHome.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/eachPharmacy.dart';
import '../../controllers/LocationController.dart';
import '../../controllers/OrderController.dart';
import '../../models/SavedLocationModel.dart';
import '../../services/PharmacyService.dart';
import '../drug/ChangePickup.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final pharmacyService = Get.find<PharmacyService>();
  final locationController = Get.find<LocationController>();
  final orderController = Get.find<OrderController>();

  final List<String> categories = [
    'All',
    // '24/7',
    'Nearby',
    // 'Popular',
    'Discount'
  ];
  String selectedCategory = 'All';
  bool isLoading = false;
  List<SavedLocation> savedLocations = [];
  bool showSavedLocations = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
    _checkLocation();
  }

  Future<void> _loadSavedLocations() async {
    savedLocations = await userService.getSavedLocations();
    setState(() {});
  }

  Future<void> _checkLocation() async {
    if (locationController.address.value.isEmpty) {
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) {
        _showLocationPrompt();
      }
    }
  }

  void _showLocationPrompt() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Delivery Location",
              style: boldTextStyle(size: 20),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.map, color: kPrimary),
              title: Text("Choose on Map"),
              onTap: () {
                Navigator.pop(context);
                ChangePickup().launch(context).then((_) => setState(() {}));
              },
            ),
            if (savedLocations.isNotEmpty) ...[
              Divider(),
              Text("Saved Locations", style: boldTextStyle()),
              ...savedLocations
                  .map((location) => ListTile(
                        leading: Icon(Icons.location_on, color: kPrimary),
                        title: Text(location.name),
                        subtitle: Text(location.address),
                        onTap: () async {
                          Navigator.pop(context);
                          await userService.setLocation(
                            location.latitude,
                            location.longitude,
                            location.address,
                          );
                          setState(() {});
                        },
                      ))
                  .toList(),
            ],
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Find Pharmacies",
                    style: boldTextStyle(size: 18, color: kPrimary),
                  ),
                  Obx(
                    () => Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimary,
                          ),
                          child: Icon(
                            Icons.shopping_cart_checkout,
                            color: white,
                          ),
                        ),
                        if (orderController.cart.isNotEmpty)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Text(
                                "${orderController.cart.length}",
                                style:
                                    secondaryTextStyle(size: 10, color: white),
                              ),
                            ),
                          ),
                      ],
                    ).onTap(() {
                      CartScreen().launch(context);
                    }),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Location Display with Saved Locations Toggle
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: kPrimary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Delivering to: ${locationController.address.value}",
                              style: primaryTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(showSavedLocations
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                            onPressed: () {
                              setState(() {
                                showSavedLocations = !showSavedLocations;
                              });
                            },
                          ),
                        ],
                      ),
                      if (showSavedLocations && savedLocations.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Container(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedLocations.length,
                            itemBuilder: (context, index) {
                              final location = savedLocations[index];
                              return SizedBox(
                                width: 200,
                                child: Card(
                                  color: context.cardColor,
                                  child: ListTile(
                                    title: Text(location.name,
                                        style: boldTextStyle(size: 12)),
                                    subtitle: Text(
                                      location.address,
                                      style: primaryTextStyle(size: 10),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await userService
                                            .deleteSavedLocation(location.id);
                                        await _loadSavedLocations();
                                      },
                                    ),
                                    onTap: () async {
                                      await userService.setLocation(
                                        location.latitude,
                                        location.longitude,
                                        location.address,
                                      );
                                      setState(() {
                                        showSavedLocations = false;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  )),
                  
              SizedBox(height: 10),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        selectedColor: kPrimary,
                        labelStyle: TextStyle(
                          color: selectedCategory == category
                              ? white
                              : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 10),

              // Pharmacy List
              Expanded(
                child: Obx(
                  () => locationController.address.value.isEmpty
                      ? _buildLocationPrompt()
                      : StreamBuilder<List<PharmacyModel>>(
                          stream: pharmacyService.getPharmaciesNearby(LatLng(
                              locationController.latitude.value,
                              locationController.longitude.value)),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildErrorState(
                                  snapshot.error.toString());
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingState();
                            }

                            if (snapshot.hasData) {
                              var data = snapshot.data!;

                              if (data.isEmpty) {
                                return _buildNoPharmaciesFound();
                              }

                              var filteredData =
                                  _filterPharmacies(data, selectedCategory);

                              return RefreshIndicator(
                                onRefresh: () async {
                                  setState(() {});
                                },
                                child: ListView.builder(
                                  itemCount: filteredData.length,
                                  itemBuilder: (context, index) {
                                    return eachPharmacy(
                                      context,
                                      filteredData[index],
                                    ).onTap(
                                      () {
                                        MedicineHome(
                                          pharmacyId:
                                              filteredData[index].id.validate(),
                                          pharmacyName: filteredData[index]
                                              .name
                                              .validate(),
                                        ).launch(context);
                                      },
                                    );
                                  },
                                ),
                              );
                            }

                            return _buildLoadingState();
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ChangePickup().launch(context).then((_) => _loadSavedLocations()),
        backgroundColor: kPrimary,
        child: Icon(Icons.add_location, color: white),
      ),
    );
  }

  List<PharmacyModel> _filterPharmacies(
      List<PharmacyModel> pharmacies, String category) {
    // Implement your actual filtering logic here
    // This is just a placeholder
    if (category == 'All') return pharmacies;
    // if (category == '24/7') {
    //   return pharmacies
    //       .where((pharmacy) => pharmacy.is24Hours ?? false)
    //       .toList();
    // }
    // if (category == 'Nearby') {
    //   return pharmacies..sort((a, b) => a.distance.compareTo(b.distance));
    // }
    // Add other filters as needed
    return pharmacies;
  }

  Widget _buildLocationPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
        SizedBox(height: 20),
        Text(
          "Location Services Required",
          style: boldTextStyle(size: 18),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "Please enable location services to find pharmacies near you",
            textAlign: TextAlign.center,
            style: primaryTextStyle(size: 14, color: Colors.grey),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => ChangePickup().launch(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            "Enable Location",
            style: boldTextStyle(color: white),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPharmaciesFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.store_mall_directory, size: 80, color: Colors.grey[400]),
        SizedBox(height: 20),
        Text(
          "No Pharmacies Found",
          style: boldTextStyle(size: 18),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "We couldn't find any pharmacies near your current location. Try adjusting your location.",
            textAlign: TextAlign.center,
            style: primaryTextStyle(size: 14, color: Colors.grey),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => ChangePickup().launch(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            "Change Location",
            style: boldTextStyle(color: white),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kPrimary),
          SizedBox(height: 20),
          Text("Finding nearby pharmacies...", style: primaryTextStyle()),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 20),
          Text("Error loading pharmacies", style: boldTextStyle(size: 16)),
          SizedBox(height: 10),
          Text(
            error,
            style: primaryTextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text("Try Again", style: boldTextStyle(color: white)),
          ),
        ],
      ),
    );
  }
}
