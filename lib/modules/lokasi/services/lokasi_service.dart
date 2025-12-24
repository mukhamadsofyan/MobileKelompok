import 'package:geolocator/geolocator.dart';

class LokasiService {
  // ================= CEK & MINTA IZIN =================
  Future<bool> checkAndRequestPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return false;
    }

    if (perm == LocationPermission.deniedForever) return false;

    return await Geolocator.isLocationServiceEnabled();
  }

  // ================= GET CURRENT POSITION =================
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.best,
  }) async {
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
      ),
    );
  }

  // ================= STREAM LOKASI =================
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 1,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
