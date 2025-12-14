import 'package:geolocator/geolocator.dart';
import 'package:orgtrack/modules/lokasi/controllers/lokasi_controller.dart';

class LokasiService {
  // CEK & MINTA IZIN
  Future<bool> checkAndRequestPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return false;
    }

    if (perm == LocationPermission.deniedForever) return false;

    return await Geolocator.isLocationServiceEnabled();
  }

  // GET CURRENT POSITION
  Future<Position> getCurrentPosition(LocationModeType mode) async {
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: mode == LocationModeType.gps
            ? LocationAccuracy.best
            : LocationAccuracy.medium,
      ),
    );
  }

  // STREAM LOKASI
  Stream<Position> getPositionStream(LocationModeType mode) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: mode == LocationModeType.gps
            ? LocationAccuracy.best
            : LocationAccuracy.medium,
        distanceFilter: 1,
      ),
    );
  }
}
