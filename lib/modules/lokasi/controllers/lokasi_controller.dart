import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:orgtrack/app/data/models/location_log_model.dart';
import 'package:orgtrack/modules/lokasi/services/lokasi_service.dart';

enum LocationModeType { gps, network }

class LokasiController extends GetxController {
  final LokasiService _service = LokasiService();

  final mapController = MapController();

  // ===================== STATE =====================
  var isLoading = false.obs;
  var hasPermission = false.obs;
  var errorMessage = ''.obs;

  var currentLatLng = const LatLng(-7.981298, 112.630432).obs;
  var accuracy = 0.0.obs;
  var lastUpdate = Rxn<DateTime>();

  var mode = LocationModeType.gps.obs;

  StreamSubscription<Position>? _streamSub;

  // ===================== POLYLINES =====================
  var pathGPS = <LatLng>[].obs;
  var pathNetwork = <LatLng>[].obs;
  var pathManual = <LatLng>[].obs;

  // Heatmap & logging
  var logs = <LocationLog>[].obs;

  // ===================== TESTING MODE =====================
  var isTesting = false.obs;
  var testMode = "Statis Outdoor".obs;
  var testDurationMinutes = 2.obs;
  var remainingSeconds = 0.obs;

  Timer? _testTimer;

  // ===================== ANIMATED MARKER =====================
  var animatedMarker = const LatLng(-7.981298, 112.630432).obs;
  Timer? _markerAnimTimer;

  @override
  void onInit() {
    super.onInit();
    initLocation();
  }

  // ===================== INIT LOCATION =====================

  Future<void> initLocation() async {
    isLoading.value = true;
    update(["main"]);

    final perm = await _service.checkAndRequestPermission();
    hasPermission.value = perm;

    if (!perm) {
      errorMessage.value =
          "Izin lokasi ditolak. Aktifkan GPS & berikan izin aplikasi.";
      isLoading.value = false;
      update(["main"]);
      return;
    }

    try {
      final pos = await _service.getCurrentPosition(mode.value);
      _applyPosition(pos);
      _startLocationStream();
    } catch (e) {
      errorMessage.value = "Gagal mengambil lokasi awal: $e";
    }

    isLoading.value = false;
    update(["main"]);
  }

  // ===================== STREAM LOCATION =====================

  void _startLocationStream() {
    _streamSub?.cancel();

    _streamSub = _service
        .getPositionStream(mode.value)
        .listen(_applyPosition, onError: (e) {
      errorMessage.value = "Error stream lokasi: $e";
    });
  }

  // ===================== MARKER ANIMATION =====================

  void _animateMarker(LatLng from, LatLng to) {
    _markerAnimTimer?.cancel();

    const int steps = 12;
    final duration = const Duration(milliseconds: 300);
    final stepDuration = duration ~/ steps;

    int i = 0;

    _markerAnimTimer =
        Timer.periodic(stepDuration, (timer) {
      if (i > steps) {
        timer.cancel();
        return;
      }

      final t = i / steps;
      final lat = from.latitude + (to.latitude - from.latitude) * t;
      final lng = from.longitude + (to.longitude - from.longitude) * t;

      animatedMarker.value = LatLng(lat, lng);
      i++;
    });
  }

  // ===================== APPLY POSITION =====================

  void _applyPosition(Position pos) {
    final newPoint = LatLng(pos.latitude, pos.longitude);
    final now = DateTime.now();

    // Distance calc
    double? dist;
    if (logs.isNotEmpty) {
      const Distance d = Distance();
      dist = d(
        LatLng(logs.last.latitude, logs.last.longitude),
        newPoint,
      );
    }

    // Log data
    logs.add(LocationLog(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      timestamp: now,
      distanceFromPrev: dist,
      mode: mode.value == LocationModeType.gps ? "GPS" : "Network",
    ));

    // Animasi marker
    _animateMarker(animatedMarker.value, newPoint);

    // Set lokasi saat ini
    currentLatLng.value = newPoint;
    accuracy.value = pos.accuracy;
    lastUpdate.value = now;

    // Tambah polyline
    if (mode.value == LocationModeType.gps) {
      pathGPS.add(newPoint);
    } else {
      pathNetwork.add(newPoint);
    }

    // Move camera
    mapController.move(newPoint, mapController.camera.zoom);
  }

  // ===================== TAP MANUAL =====================

  void onMapTapped(LatLng point) {
    _markerAnimTimer?.cancel();

    animatedMarker.value = point;
    currentLatLng.value = point;

    mapController.move(point, mapController.camera.zoom);

    pathManual.add(point);

    logs.add(LocationLog(
      latitude: point.latitude,
      longitude: point.longitude,
      accuracy: 0.0,
      timestamp: DateTime.now(),
      distanceFromPrev: null,
      mode: "Manual Tap",
    ));
  }

  // ===================== SWITCH MODE =====================

  void switchMode(LocationModeType newMode) async {
    if (mode.value == newMode) return;

    mode.value = newMode;

    await initLocation();
    update(["main"]);
  }

  // ===================== TESTING MODE =====================

  void setTestMode(String m) => testMode.value = m;

  void setTestDuration(int m) => testDurationMinutes.value = m;

  void startTesting() {
    if (!hasPermission.value) {
      errorMessage.value = "Izin lokasi belum aktif.";
      return;
    }

    isTesting.value = true;
    logs.clear();

    remainingSeconds.value = testDurationMinutes.value * 60;

    _recordExperiment();

    _testTimer?.cancel();
    _testTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value <= 0) {
        stopTesting();
        return;
      }

      remainingSeconds.value--;

      if (remainingSeconds.value % 15 == 0) {
        _recordExperiment();
      }
    });
  }

  void stopTesting() {
    isTesting.value = false;
    _testTimer?.cancel();
  }

  void _recordExperiment() {
    final p = currentLatLng.value;

    logs.add(LocationLog(
      latitude: p.latitude,
      longitude: p.longitude,
      accuracy: accuracy.value,
      timestamp: DateTime.now(),
      distanceFromPrev: null,
      mode: "TEST ${testMode.value} (${mode.value.name})",
    ));
  }

  @override
  void onClose() {
    _streamSub?.cancel();
    _markerAnimTimer?.cancel();
    _testTimer?.cancel();
    super.onClose();
  }
}
