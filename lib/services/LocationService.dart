import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:instant_doctor/services/GetUserId.dart';

class LocationService {
  static const String apiKey =
      'AIzaSyD8nW2BRd9ssOWqimiF-dOS4IeaXkKoBCI'; // Replace with your key
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  Future<LocationResult> getLocationFromPlaceId(String placeId) async {
    final url = '$_baseUrl/place/details/json?'
        'place_id=$placeId'
        '&fields=address_component,formatted_address,geometry'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final result = jsonResponse['result'];
      final location = result['geometry']['location'];

      // Parse the address components to get a cleaner address
      final address = parseAddressComponents(result['address_components']);

      return LocationResult(
        position: LatLng(location['lat'], location['lng']),
        address: address.isNotEmpty ? address : result['formatted_address'],
      );
    } else {
      throw Exception('Failed to load location: ${response.statusCode}');
    }
  }

  String parseAddressComponents(List<dynamic> components) {
    String street = '';
    String streetNumber = '';
    String neighborhood = '';
    String locality = '';

    for (var component in components) {
      final types = component['types'];
      if (types.contains('street_number')) {
        streetNumber = component['long_name'];
      } else if (types.contains('route')) {
        street = component['long_name'];
      } else if (types.contains('neighborhood') ||
          types.contains('sublocality')) {
        neighborhood = component['long_name'];
      } else if (types.contains('locality')) {
        locality = component['long_name'];
      }
    }

    // Build a clean address string
    final addressParts = [
      if (streetNumber.isNotEmpty) streetNumber,
      street,
      if (neighborhood.isNotEmpty && neighborhood != locality) neighborhood,
      locality
    ].where((part) => part.isNotEmpty).toList();

    return addressParts.join(', ');
  }

  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    final url = '$_baseUrl/place/autocomplete/json?'
        'input=$query'
        // '&types=address'
        // '&components=country:ng'
        '&location=${locationController.latitude.value},${locationController.longitude.value}'
        '&region=ng'
        '&radius=1000'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['predictions'] as List).map((prediction) {
        return LocationSuggestion(
          description: prediction['description'],
          placeId: prediction['place_id'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }
}

class LocationResult {
  final LatLng position;
  final String address;

  LocationResult({
    required this.position,
    required this.address,
  });
}

class LocationSuggestion {
  final String description;
  final String placeId;

  LocationSuggestion({
    required this.description,
    required this.placeId,
  });
}
