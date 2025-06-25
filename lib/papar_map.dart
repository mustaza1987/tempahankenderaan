import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';

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
      appBar: AppBar(title: Text('Peta Lokasi'), backgroundColor: Colors.blue),
      body: kIsWeb ? _buildFlutterMap(latLng) : _buildGoogleMap(latLng),
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
          infoWindow: gmap.InfoWindow(title: lokasi),
        ),
      },
      onMapCreated: (gmap.GoogleMapController controller) {},
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
