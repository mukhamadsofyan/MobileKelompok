import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/lokasi_controller.dart';

class LokasiView extends GetView<LokasiController> {
  const LokasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            controller.mode.value == LocationModeType.gps
                ? "GPS Location"
                : "Network Location",
          );
        }),
      ),

      // BODY UTAMA
      body: GetBuilder<LokasiController>(
        id: "main",
        builder: (_) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasPermission.value) {
            return _noPermission();
          }

          return Column(
            children: [
              _mapSection(),
              Expanded(child: _bottomPanel(context)),
            ],
          );
        },
      ),
    );
  }

  // ===================== NO PERMISSION =====================

  Widget _noPermission() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== MAP SECTION =====================

  Widget _mapSection() {
    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),

        child: FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: controller.currentLatLng.value,
            initialZoom: 17,
            onTap: (tapPos, tappedPoint) => controller.onMapTapped(tappedPoint),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "orgtrack.app",
            ),

            // Polyline GPS
            Obx(() => PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.pathGPS.toList(),
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                )),

            // Polyline Network
            Obx(() => PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.pathNetwork.toList(),
                      strokeWidth: 4,
                      color: Colors.red,
                    ),
                  ],
                )),

            // Polyline Manual
            Obx(() => PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.pathManual.toList(),
                      strokeWidth: 4,
                      color: Colors.orange,
                    ),
                  ],
                )),

            // Heatmap
            Obx(() => CircleLayer(
                  circles: controller.logs.map((log) {
                    return CircleMarker(
                      point: LatLng(log.latitude, log.longitude),
                      radius: 10,
                      color: _accuracyColor(log.accuracy),
                    );
                  }).toList(),
                )),

            // Marker posisi sekarang
            Obx(() => MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.currentLatLng.value,
                      width: 55,
                      height: 55,
                      child: const Icon(
                        Icons.location_pin,
                        size: 55,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(double acc) {
    if (acc <= 5) return Colors.green.withOpacity(0.6);
    if (acc <= 15) return Colors.yellow.withOpacity(0.6);
    return Colors.red.withOpacity(0.6);
  }

  // ===================== PANEL BAWAH =====================

  Widget _bottomPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _providerHeaderCard(),
          const SizedBox(height: 16),
          _locationInfoCard(),
          const SizedBox(height: 16),
          _testPanel(context),
          const SizedBox(height: 16),
          _logCard(),
        ],
      ),
    );
  }

  // ===================== PROVIDER HEADER =====================

  Widget _providerHeaderCard() {
    return _card(
      child: Obx(() {
        final isGPS = controller.mode.value == LocationModeType.gps;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGPS ? Icons.satellite_alt : Icons.network_cell,
                  size: 26,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Text(
                  isGPS ? "GPS Provider Location" : "Network Provider Location",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () => controller.initLocation(),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isGPS ? Colors.teal : Colors.grey.shade300,
                      foregroundColor:
                          isGPS ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () =>
                        controller.switchMode(LocationModeType.gps),
                    child: const Text("GPS"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isGPS ? Colors.teal : Colors.grey.shade300,
                      foregroundColor:
                          !isGPS ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () =>
                        controller.switchMode(LocationModeType.network),
                    child: const Text("Network"),
                  ),
                ),
              ],
            )
          ],
        );
      }),
    );
  }

  // ===================== LOCATION INFO =====================

  Widget _locationInfoCard() {
    return _card(
      child: Obx(() {
        final p = controller.currentLatLng.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 6),
                Text(
                  "Location Info",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _infoRow(
              icon: Icons.north,
              label: "Latitude",
              value: p.latitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 8),

            _infoRow(
              icon: Icons.south,
              label: "Longitude",
              value: p.longitude.toStringAsFixed(6),
            ),

            const Divider(height: 25),

            _infoRow(
              icon: Icons.my_location,
              label: "Accuracy",
              value: "${controller.accuracy.value.toStringAsFixed(1)} m",
            ),
            const SizedBox(height: 8),

            _infoRow(
              icon: Icons.access_time,
              label: "Waktu",
              value: controller.lastUpdate.value == null
                  ? "-"
                  : controller.lastUpdate.value!
                      .toLocal()
                      .toString()
                      .split(".")
                      .first,
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.copy, size: 18, color: Colors.grey),
      ],
    );
  }

  // ===================== TEST PANEL =====================

  Widget _testPanel(BuildContext context) {
    return _card(
      child: Obx(() {
        final c = controller;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mode Pengujian Akurasi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            DropdownButton<String>(
              value: c.testMode.value,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: "Statis Outdoor", child: Text("Statis Outdoor")),
                DropdownMenuItem(
                    value: "Statis Indoor", child: Text("Statis Indoor")),
                DropdownMenuItem(
                    value: "Dinamis (Bergerak)",
                    child: Text("Dinamis (Bergerak)")),
              ],
              onChanged: (v) => c.setTestMode(v!),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: [1, 2, 5].map((m) {
                return ChoiceChip(
                  label: Text("$m menit"),
                  selected: c.testDurationMinutes.value == m,
                  onSelected: (_) => c.setTestDuration(m),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            if (c.isTesting.value)
              Text(
                "Sisa waktu: ${c.remainingSeconds ~/ 60}m "
                "${(c.remainingSeconds % 60).toString().padLeft(2, '0')}s",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon:
                  Icon(c.isTesting.value ? Icons.stop : Icons.play_arrow),
              label: Text(
                  c.isTesting.value ? "Stop Testing" : "Mulai Testing"),
              onPressed: () {
                c.isTesting.value ? c.stopTesting() : c.startTesting();
              },
            ),
          ],
        );
      }),
    );
  }

  // ===================== LOG LIST =====================

  Widget _logCard() {
    return _card(
      child: Obx(() {
        if (controller.logs.isEmpty) {
          return const Text("Belum ada log lokasi");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Log Lokasi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            ListView.builder(
              itemCount: controller.logs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                final log = controller.logs[i];

                return ListTile(
                  leading: const Icon(Icons.location_searching),
                  title: Text(
                      "(${log.latitude.toStringAsFixed(6)}, ${log.longitude.toStringAsFixed(6)})"),
                  subtitle: Text(
                    "Mode: ${log.mode}\n"
                    "Akurasi: ${log.accuracy} m\n"
                    "Waktu: ${log.timestamp.toLocal().toString().split('.').first}",
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  // ===================== REUSABLE CARD =====================

  Widget _card({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
