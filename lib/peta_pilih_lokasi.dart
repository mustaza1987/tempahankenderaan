import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geocoding/geocoding.dart';

class PetaPilihLokasi extends StatefulWidget {
  const PetaPilihLokasi({super.key});

  @override
  State<PetaPilihLokasi> createState() => _PetaPilihLokasiState();
}

class _PetaPilihLokasiState extends State<PetaPilihLokasi> {
  GoogleMapController? mapController;
  LatLng? selectedLocation; // Untuk mobile
  latlong.LatLng? selectedLocationWeb; // Untuk web
  String selectedAddress = "";

  Future<void> _getLocation(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          if (kIsWeb) {
            selectedLocationWeb = latlong.LatLng(lat, lng);
          } else {
            selectedLocation = LatLng(lat, lng);
          }

          selectedAddress =
              "${place.name ?? ''}, ${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}"
                  .replaceAll(RegExp(r'(, )+'), ', ')
                  .trim()
                  .replaceAll(RegExp(r'^,+|,+$'), '');
        });
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
      setState(() {
        selectedAddress = "Alamat tidak dapat ditentukan.";
      });
    }
  }

  void _pilihLokasi() {
    final lat = kIsWeb
        ? selectedLocationWeb?.latitude
        : selectedLocation?.latitude;
    final lng = kIsWeb
        ? selectedLocationWeb?.longitude
        : selectedLocation?.longitude;

    if (selectedAddress.isNotEmpty && lat != null && lng != null) {
      Navigator.pop(context, {
        "address": selectedAddress,
        "lat": lat,
        "lng": lng,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _buildWebMap(context) : _buildMobileMap(context);
  }

  Widget _buildMobileMap(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Destinasi")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.1390, 101.6869), // Kuala Lumpur
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            onTap: (position) =>
                _getLocation(position.latitude, position.longitude),
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedLocation!,
                    ),
                  }
                : {},
          ),
          if (selectedAddress.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    selectedAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pilihLokasi,
        label: const Text("Pilih Lokasi"),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildWebMap(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Destinasi (Web)")),
      body: fm.FlutterMap(
        options: fm.MapOptions(
          center: latlong.LatLng(3.1390, 101.6869),
          zoom: 13.0,
          onTap: (_, pos) => _getLocation(pos.latitude, pos.longitude),
        ),
        children: [
          fm.TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          fm.MarkerLayer(
            markers: selectedLocationWeb != null
                ? [
                    fm.Marker(
                      point: selectedLocationWeb!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ]
                : [],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pilihLokasi,
        label: const Text("Pilih Lokasi"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
