import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LokasiSekretariatController extends GetxController {
  /// Koordinat Sekretariat UMM
  final LatLng umm = const LatLng(
    -7.921350,
    112.596130,
  );

  /// Buka Google Maps
  Future<void> openMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${umm.latitude},${umm.longitude}';

    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      Get.snackbar(
        "Error",
        "Tidak dapat membuka Google Maps",
      );
    }
  }
}
