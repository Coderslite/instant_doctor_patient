import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/services/LocationService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import '../../constant/color.dart';
import '../../controllers/LocationController.dart';
import '../../controllers/OrderController.dart';
import '../../controllers/UserController.dart';
import '../../main.dart';
import '../../services/UserService.dart';

class ChangePickup extends StatefulWidget {
  const ChangePickup({super.key});

  @override
  State<ChangePickup> createState() => _ChangePickupState();
}

class _ChangePickupState extends State<ChangePickup> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final Completer<GoogleMapController> _mapController = Completer();

  String _address = '';
  bool _isLoading = false;
  bool _isMapReady = false;
  List<LocationSuggestion> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (Get.find<LocationController>().latitude.value == 0 &&
        Get.find<LocationController>().longitude.value == 0) {
      await Get.find<LocationController>().handleGetMyLocation();
    }

    if (Get.find<LocationController>().address.value.isNotEmpty) {
      _address = Get.find<LocationController>().address.value;
      _searchController.text = _address;
    }
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    applyMapStyle(context);
    setState(() => _isMapReady = true);
  }

  Future<void> _moveToLocation(LatLng position) async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 18),
    ));
    await _updateAddress(position);
  }

  Future<void> _updateAddress(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      // First try with Google's reverse geocoding
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?'
          'latlng=${position.latitude},${position.longitude}'
          '&key=${LocationService.apiKey}';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final components = data['results'][0]['address_components'];
          _address = _locationService.parseAddressComponents(components);
          _searchController.text = _address;
          setState(() {});
          return;
        }
      }

      // Fallback to geocoding package if Google fails
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _address = [
          place.street,
          place.subLocality,
          place.locality,
        ].where((p) => p?.isNotEmpty ?? false).join(', ');

        _searchController.text = _address;
        setState(() {});
      }
    } catch (e) {
      toast('Could not get address details');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSearchChanged(String query) async {
    if (query.length > 2) {
      try {
        _suggestions = await _locationService.getSuggestions(query);
        setState(() => _showSuggestions = true);
      } catch (e) {
        toast('Could not fetch suggestions');
      }
    } else {
      setState(() => _showSuggestions = false);
    }
  }

  Future<void> _handlePlaceSelected(LocationSuggestion suggestion) async {
    try {
      setState(() {
        _isLoading = true;
        _showSuggestions = false;
      });

      final result =
          await _locationService.getLocationFromPlaceId(suggestion.placeId);
      await _moveToLocation(result.position);
      _address = result.address;
      _searchController.text = _address;
      FocusScope.of(context).unfocus();
    } catch (e) {
      toast('Failed to get location details');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocation() async {
    if (_address.isEmpty) return;

    final locController = Get.find<LocationController>();
    locController.address.value = _address;

    await Get.find<UserService>().updateProfile(
      userId: Get.find<UserController>().userId.value,
      data: {
        "location": GeoPoint(
          locController.latitude.value,
          locController.longitude.value,
        ),
        "address": _address,
      },
    );

    Get.find<OrderController>().getTotalDeliveryFee();
    Navigator.pop(context);
  }

  Future<String> _loadMapStyle(BuildContext context, bool isDarkMode) async {
    String stylePath = isDarkMode
        ? 'assets/googlemap/map_style_dark.json'
        : 'assets/googlemap/map_style_light.json';
    return await DefaultAssetBundle.of(context).loadString(stylePath);
  }

  Future<void> applyMapStyle(BuildContext context) async {
    String mapStyle =
        await _loadMapStyle(context, settingsController.isDarkMode.isTrue);
    _mapController.future.then((controller) {
      controller.setMapStyle(mapStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          if (Get.find<LocationController>().latitude.value != 0 &&
              Get.find<LocationController>().longitude.value != 0)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  Get.find<LocationController>().latitude.value,
                  Get.find<LocationController>().longitude.value,
                ),
                zoom: 18,
              ),
              onMapCreated: _onMapCreated,
              onCameraMove: (position) {
                Get.find<LocationController>().latitude.value =
                    position.target.latitude;
                Get.find<LocationController>().longitude.value =
                    position.target.longitude;
              },
              onCameraIdle: () => _updateAddress(
                LatLng(
                  Get.find<LocationController>().latitude.value,
                  Get.find<LocationController>().longitude.value,
                ),
              ),
              myLocationEnabled: true,
            )
          else
            Loader().center(),

          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Card(
                  color: context.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: primaryTextStyle(),
                          decoration: InputDecoration(
                            hintText: 'Enter delivery address',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: _handleSearchChanged,
                          onTap: () => setState(() => _showSuggestions = true),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _showSuggestions = false);
                          },
                        ),
                    ],
                  ),
                ),

                // Suggestions List
                if (_showSuggestions && _suggestions.isNotEmpty)
                  Card(
                    color: context.cardColor,
                    elevation: 4,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(
                            suggestion.description,
                            style: primaryTextStyle(),
                          ),
                          onTap: () => _handlePlaceSelected(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Custom Marker with Address Tooltip
          if (!_showSuggestions)
            IgnorePointer(
              ignoring: true,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_address.isNotEmpty && !_isLoading)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _address,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    // Your custom marker image
                    Image.asset(
                      'assets/images/marker.webp', // Your custom marker path
                      width: 48,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Confirm Button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, // Your primary color
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _address.isNotEmpty ? _saveLocation : null,
              child: Text(
                'CONFIRM DELIVERY LOCATION',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading) Center(child: Loader()),
        ],
      ),
    );
  }
}
