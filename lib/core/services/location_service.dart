import 'package:geolocator/geolocator.dart';

class LocationService {
  static final instance = LocationService._();
  LocationService._();

  bool _isGranted = false;
  bool get isPermissionGranted => _isGranted;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isGranted = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isGranted = false;
      return false;
    }

    _isGranted = true;
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    if (!_isGranted) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  // 4. Streaming Desteği
  Stream<Position> get positionStream => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10 metrede bir güncelle
    ),
  );
}
