import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class Getmycountry {
  Future<String> handleGetCountry(LatLng location) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    var res = placemarks.first.country.validate().toLowerCase();
    return res;
  }
}
