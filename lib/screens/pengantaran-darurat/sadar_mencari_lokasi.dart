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

      List<LatLng> polyPoints =
          coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();

      setState(() => routeLine = polyPoints);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(-7.2756, 112.6426),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.sahabat_rs",
              ),

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

              if (destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: destination!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.flag,
                          size: 40, color: Colors.purple),
                    )
                  ],
                ),
            ],
          ),

          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/home'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 28),
              ),
            ),
          ),

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
                        ? () {
                            Navigator.pushNamed(context, "/konfirmasi");
                          }
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