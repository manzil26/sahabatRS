import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SadarMencariLokasi extends StatefulWidget {
  const SadarMencariLokasi({super.key});

  @override
  State<SadarMencariLokasi> createState() => _SadarMencariLokasiState();
}

class _SadarMencariLokasiState extends State<SadarMencariLokasi> {
  final MapController mapController = MapController();

  LatLng? pickup;
  LatLng? destination;

  List<dynamic> searchResults = [];
  List<LatLng> routeLine = [];

  bool isSearchingPickup = true;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  /// 🔍 Search OSM
  void searchLocation(String query) async {
    if (query.length < 3) {
      setState(() => searchResults = []);
      return;
    }

    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() => searchResults = jsonDecode(response.body));
    }
  }

  /// 📍 Select hasil search
  void selectLocation(dynamic place) {
    final lat = double.parse(place["lat"]);
    final lon = double.parse(place["lon"]);
    final point = LatLng(lat, lon);

    setState(() {
      if (isSearchingPickup) {
        pickup = point;
        pickupController.text = place["display_name"];
      } else {
        destination = point;
        destinationController.text = place["display_name"];
      }
      searchResults = [];
    });

    mapController.move(point, 16);

    if (pickup != null && destination != null) {
      getRouteOSRM();
    }
  }

  /// 🚗 Mendapatkan rute dari OSRM (jalan asli, bukan garis lurus)
  Future<void> getRouteOSRM() async {
    final url = Uri.parse(
      "https://router.project-osrm.org/route/v1/driving/"
      "${pickup!.longitude},${pickup!.latitude};"
      "${destination!.longitude},${destination!.latitude}"
      "?overview=full&geometries=geojson",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final coords = data["routes"][0]["geometry"]["coordinates"];

      List<LatLng> polyPoints = coords
          .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      setState(() => routeLine = polyPoints);
    }
  }

  /// 🧡 Popup driver ketika klik "Pesan"
  void showDriverPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Driver Sedang Menuju Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Budi Santoso",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Motor Beat 2020 • L 1234 XX",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                )
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Tutup",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🗺 MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(-7.2756, 112.6426),
              initialZoom: 15,
              onTap: (tapPos, point) {
                setState(() {
                  if (pickup == null) {
                    pickup = point;
                    pickupController.text =
                        "${point.latitude}, ${point.longitude}";
                  } else if (destination == null) {
                    destination = point;
                    destinationController.text =
                        "${point.latitude}, ${point.longitude}";
                  } else {
                    pickup = point;
                    pickupController.text =
                        "${point.latitude}, ${point.longitude}";
                    destination = null;
                    destinationController.clear();
                  }
                });

                if (pickup != null && destination != null) {
                  getRouteOSRM();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.sahabat_rs",
              ),

              /// 🔵 RUTE OSRM
              if (routeLine.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeLine,
                      strokeWidth: 5,
                      color: Colors.blue,
                    )
                  ],
                ),

              /// MARKER PICKUP
              if (pickup != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickup!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin,
                          size: 40, color: Colors.orange),
                    )
                  ],
                ),

              /// MARKER DESTINATION
              if (destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: destination!,
                      width: 40,
                      height: 40,
                      child:
                          const Icon(Icons.flag, size: 40, color: Colors.purple),
                    )
                  ],
                ),
            ],
          ),

          /// 🔍 SEARCH RESULT LIST
          if (searchResults.isNotEmpty)
            Positioned(
              left: 15,
              right: 15,
              bottom: 230,
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final place = searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(place["display_name"]),
                      onTap: () => selectLocation(place),
                    );
                  },
                ),
              ),
            ),

          /// 🟧 PANEL BAWAH (INPUT + BUTTON)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pickupController,
                    onTap: () => setState(() => isSearchingPickup = true),
                    onChanged: searchLocation,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.orange),
                      hintText: "Lokasi kamu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: destinationController,
                    onTap: () => setState(() => isSearchingPickup = false),
                    onChanged: searchLocation,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.local_hospital,
                          color: Colors.purple),
                      hintText: "Tujuan Rumah Sakit",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: (pickup != null && destination != null)
                        ? showDriverPopup
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Pesan",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
