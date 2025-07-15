import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class PaparMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String lokasi;

  const PaparMapPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.lokasi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng latLng = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Lokasi'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          kIsWeb ? _buildFlutterMap(latLng) : _buildGoogleMap(latLng),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white.withOpacity(0.85),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    lokasi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openInGoogleMaps(latitude, longitude),
                    icon: const Icon(Icons.map),
                    label: const Text('Buka di Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FlutterMap for web
  Widget _buildFlutterMap(LatLng latLng) {
    return fmap.FlutterMap(
      options: fmap.MapOptions(center: latLng, zoom: 16),
      children: [
        fmap.TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        fmap.MarkerLayer(
          markers: [
            fmap.Marker(
              width: 40,
              height: 40,
              point: latLng,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// GoogleMap for mobile
  Widget _buildGoogleMap(LatLng latLng) {
    return gmap.GoogleMap(
      initialCameraPosition: gmap.CameraPosition(
        target: gmap.LatLng(latLng.latitude, latLng.longitude),
        zoom: 16,
      ),
      markers: {
        gmap.Marker(
          markerId: const gmap.MarkerId('lokasi'),
          position: gmap.LatLng(latLng.latitude, latLng.longitude),
          infoWindow: gmap.InfoWindow(
            title: lokasi,
            snippet:
                '(${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})',
          ),
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (gmap.GoogleMapController controller) {},
    );
  }

  /// Launch Google Maps
  void _openInGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat buka Google Maps.';
    }
  }
}
