import 'package:geolocator/geolocator.dart';

class LocationUtils {

  static Future<Position?> getCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    /// Check if location service enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location service disabled");
      return null;
    }

    /// Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ Location permission denied forever");
      return null;
    }

    /// Get location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}