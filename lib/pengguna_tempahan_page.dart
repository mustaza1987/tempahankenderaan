import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'profil_pengguna.dart';
import 'sejarah_tempahan.dart';
import 'tempah_kenderaan_page.dart';
import 'papar_map.dart';

class PenggunaTempahanPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const PenggunaTempahanPage({super.key, required this.user});

  @override
  State<PenggunaTempahanPage> createState() => _PenggunaTempahanPageState();
}

class _PenggunaTempahanPageState extends State<PenggunaTempahanPage> {
  Widget buildMiniMap({required double lat, required double lng}) {
    if (kIsWeb) {
      return SizedBox(
        height: 150,
        child: ClipRRect(
          //container biasa
          borderRadius: BorderRadius.circular(10), //box decoration
          child: fmap.FlutterMap(
            options: fmap.MapOptions(center: LatLng(lat, lng), zoom: 14.0),
            children: [
              fmap.TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', //ada nilai
                subdomains: const ['a', 'b', 'c'],
              ),
              fmap.MarkerLayer(
                markers: [
                  fmap.Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 150,
        child: ClipRRect(
          // TODO: container
          borderRadius: BorderRadius.circular(10),
          child: gmap.GoogleMap(
            initialCameraPosition: gmap.CameraPosition(
              target: gmap.LatLng(lat, lng),
              zoom: 14,
            ),
            markers: {
              gmap.Marker(
                markerId: const gmap.MarkerId('lokasi'),
                position: gmap.LatLng(lat, lng),
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            liteModeEnabled: true,
          ),
        ),
      );
    }
  }

  Widget miniMap(double lat, double lng) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(lat, lng),
            zoom: 15,
            interactiveFlags: InteractiveFlag.none,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(lat, lng),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _selectedIndex = 0;
  bool _showSenaraiTempahan = false;
  bool _isLoading = false;
  List<dynamic> _senaraiTempahan = [];

  @override
  void initState() {
    super.initState();
    fetchTempahanBaru();
  }

  Future<void> fetchTempahanBaru() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(
          "http://10.20.18.184/kenderaanALL/flutapi/get_tempahan_baru.php",
        ),
        body: {'id_pengguna': widget.user['id_pengguna'].toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _senaraiTempahan = data['tempahan'] ?? [];
        });
      }
    } catch (_) {
      setState(() => _senaraiTempahan = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool isKoordinat(String lokasi) {
    final parts = lokasi.split(',');
    return parts.length == 2 &&
        double.tryParse(parts[0].trim()) != null &&
        double.tryParse(parts[1].trim()) != null;
  }

  String googleStaticMapUrl(String lokasi) {
    final lat = lokasi.split(',')[0].trim();
    final lng = lokasi.split(',')[1].trim();
    const apiKey = 'AIzaSyC_bqVK_wE9Qo49UqWKhH_XsQFcBYqI9NE';
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$lng'
        '&zoom=15'
        '&size=600x300'
        '&markers=color:red%7C$lat,$lng'
        '&key=$apiKey';
  }

  void _bukaPetaDestinasi(String destinasi) {
    final koordinat = destinasi.split(',');
    if (koordinat.length == 2) {
      final lat = double.tryParse(
        koordinat[0].replaceAll(RegExp('[^0-9.-]'), ''),
      );
      final lng = double.tryParse(
        koordinat[1].replaceAll(RegExp('[^0-9.-]'), ''),
      );

      if (lat != null && lng != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PaparMapPage(latitude: lat, longitude: lng, lokasi: destinasi),
          ),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi tidak sah untuk paparan peta.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Log Keluar"),
          content: const Text("Adakah anda pasti ingin log keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("Ya"),
            ),
          ],
        ),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Color getStatusColor(dynamic status) {
    switch (status.toString()) {
      case '1':
        return Colors.orange;
      case '2':
        return Colors.green;
      case '3':
        return Colors.red;
      case '4':
        return Colors.limeAccent;
      case '5':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(dynamic status) {
    switch (status.toString()) {
      case '1':
        return "Baru";
      case '2':
        return "Lulus";
      case '3':
        return "Tidak Lulus";
      case '4':
        return "Selesai";
      case '5':
        return "Dipanjangkan ke BKP";
      default:
        return "Batal";
    }
  }

  String formatTarikh(String tarikh) {
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(tarikh.split(' - ')[0]);
      return DateFormat('dd MMM yyyy', 'ms_MY').format(parsedDate);
    } catch (_) {
      return tarikh;
    }
  }

  Future<void> cetakTempahanPDF(Map<String, dynamic> item) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(font: ttf, fontSize: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Butiran Tempahan",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text("Nama: ${widget.user['nama']}"),
                pw.Text("Destinasi: ${item['destinasi']}"),
                pw.Text("Tarikh: ${formatTarikh(item['tarikh'])}"),
                pw.Text("Tempat Lapor Diri: ${item['tempat_lapor']}"),
                pw.Text("Status: ${getStatusText(item['id_status_tempahan'])}"),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Widget buildWelcomePage() {
    return RefreshIndicator(
      onRefresh: fetchTempahanBaru,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.user['nama'] ?? 'Pengguna',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () =>
                  setState(() => _showSenaraiTempahan = !_showSenaraiTempahan),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _senaraiTempahan.isNotEmpty
                            ? ' Terdapat ${_senaraiTempahan.length} tempahan sedang diproses (sentuh untuk lihat)'
                            : 'Tiada tempahan sedang diproses.',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const Icon(Icons.expand_more),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_showSenaraiTempahan && _senaraiTempahan.isNotEmpty)
              ..._senaraiTempahan.map((item) {
                final destinasi =
                    item['destinasi'] ?? 'Destinasi Tidak Dikenal Pasti';
                double? lat;
                double? lng;
                final regex = RegExp(
                  r'Lat:\s*([\-\\d.]+),\s*Lng:\s*([\-\\d.]+)',
                );
                final match = regex.firstMatch(destinasi);
                if (match != null) {
                  lat = double.tryParse(match.group(1)!);
                  lng = double.tryParse(match.group(2)!);
                }

                final isCoord = isKoordinat(destinasi);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isCoord
                                    ? 'Lat: ${destinasi.split(',')[0].trim()}, Lng: ${destinasi.split(',')[1].trim()}'
                                    : destinasi,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () => cetakTempahanPDF(item),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text("Tarikh: ${formatTarikh(item['tarikh'])}"),
                        Text("Tempat Lapor: ${item['tempat_lapor']}"),
                        Text(
                          "Status: ${getStatusText(item['id_status_tempahan'])}",
                          style: TextStyle(
                            color: getStatusColor(item['id_status_tempahan']),
                          ),
                        ),
                        if (isCoord) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _bukaPetaDestinasi(destinasi),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: miniMap(
                                double.parse(destinasi.split(',')[0].trim()),
                                double.parse(destinasi.split(',')[1].trim()),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),
            Text(
              "Menu Utama",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuCard(
                  Icons.history,
                  "Sejarah Tempahan",
                  Colors.teal,
                  () => _onItemTapped(1),
                ),
                _buildMenuCard(
                  Icons.directions_car,
                  "Tempah Kenderaan",
                  Colors.blue,
                  () => _onItemTapped(2),
                ),
                _buildMenuCard(
                  Icons.person,
                  "Profil Pengguna",
                  Colors.deepPurple,
                  () => _onItemTapped(3),
                ),
                _buildMenuCard(
                  Icons.logout,
                  "Log Keluar",
                  Colors.redAccent,
                  () => _onItemTapped(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            isSelected ? label : '',
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildWelcomePage(),
      SejarahTempahanPage(idPengguna: widget.user['id_pengguna']),
      TempahKenderaanPage(user: widget.user),
      ProfilPenggunaPage(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tempah Kenderaan',
        onPressed: () => setState(() => _selectedIndex = 2),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.car_repair_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.home, 'Menu', 0),
              _buildNavIcon(Icons.history, 'Sejarah', 1),
              const SizedBox(width: 40),
              _buildNavIcon(Icons.person, 'Profil', 3),
              _buildNavIcon(Icons.logout, 'Keluar', 4),
            ],
          ),
        ),
      ),
    );
  }
}
