import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SejarahTempahanPage extends StatefulWidget {
  final int idPengguna;

  const SejarahTempahanPage({super.key, required this.idPengguna});

  @override
  _SejarahTempahanPageState createState() => _SejarahTempahanPageState();
}

class _SejarahTempahanPageState extends State<SejarahTempahanPage> {
  List<dynamic> _senaraiTempahan = [];
  bool _loading = true;
  DateTime? _tarikhMula;
  DateTime? _tarikhTamat;

  @override
  void initState() {
    super.initState();
    fetchSejarahTempahan();
  }

  Future<void> fetchSejarahTempahan() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://10.20.18.184/kenderaanALL/flutapi/sejarah_tempahan.php?id_pengguna=${widget.idPengguna}",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "success") {
          setState(() {
            _senaraiTempahan = data["data"];
            _loading = false;
          });
        } else {
          throw Exception(data["message"]);
        }
      } else {
        throw Exception("Gagal ambil data dari server");
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ralat: ${e.toString()}")));
    }
  }

  Color statusColor(int idStatus) {
    switch (idStatus) {
      case 1:
        return Colors.grey; // Baru
      case 2:
        return Colors.green; // Lulus
      case 3:
        return Colors.red; // Tidak Lulus
      case 4:
        return Colors.blue; // Selesai
      case 5:
        return Colors.orange; // Dipanjangkan ke BKP
      case 6:
        return Colors.black; // Batal
      default:
        return Colors.grey;
    }
  }

  List<dynamic> _filteredTempahan() {
    if (_tarikhMula == null && _tarikhTamat == null) return _senaraiTempahan;
    return _senaraiTempahan.where((item) {
      final t =
          DateTime.tryParse(item['tarikh_bertolak'] ?? '') ?? DateTime(2000);
      if (_tarikhMula != null && t.isBefore(_tarikhMula!)) return false;
      if (_tarikhTamat != null && t.isAfter(_tarikhTamat!)) return false;
      return true;
    }).toList();
  }

  Widget buildDateFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                _tarikhMula == null
                    ? 'Tarikh Mula'
                    : DateFormat('yyyy-MM-dd').format(_tarikhMula!),
              ),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _tarikhMula = picked);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                _tarikhTamat == null
                    ? 'Tarikh Tamat'
                    : DateFormat('yyyy-MM-dd').format(_tarikhTamat!),
              ),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _tarikhTamat = picked);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget buildMiniMap({required double lat, required double lng}) {
    if (kIsWeb) {
      return SizedBox(
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: fmap.FlutterMap(
            options: fmap.MapOptions(center: LatLng(lat, lng), zoom: 14.0),
            children: [
              fmap.TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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

  Widget buildTempahanCard(Map<String, dynamic> item) {
    final destinasi = item['destinasi'] ?? 'Destinasi Tidak Dikenal Pasti';
    final tarikhBertolak = item['tarikh_bertolak'] ?? '';
    final masaBertolak = item['masa_bertolak'] ?? '';
    final tarikhBalik = item['tarikh_balik'] ?? '';
    final masaBalik = item['masa_balik'] ?? '';
    final status = item['status_tempahan'] ?? 'Tidak Diketahui';
    final idStatus = int.tryParse(item['id_status_tempahan'].toString()) ?? 0;

    double? lat;
    double? lng;

    final regex = RegExp(r'Lat:\s*([\-\d.]+),\s*Lng:\s*([\-\d.]+)');
    final match = regex.firstMatch(destinasi);
    if (match != null) {
      lat = double.tryParse(match.group(1)!);
      lng = double.tryParse(match.group(2)!);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaparanTempahanPage(item: item)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      destinasi,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "$tarikhBertolak $masaBertolak → $tarikhBalik $masaBalik",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                "Status: $status",
                style: TextStyle(fontSize: 14, color: statusColor(idStatus)),
              ),
              if (lat != null && lng != null) ...[
                const SizedBox(height: 12),
                buildMiniMap(lat: lat, lng: lng),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sejarah Tempahan")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildDateFilters(),
                Expanded(
                  child: _filteredTempahan().isEmpty
                      ? const Center(child: Text("Tiada sejarah tempahan"))
                      : ListView.builder(
                          itemCount: _filteredTempahan().length,
                          itemBuilder: (context, index) {
                            return buildTempahanCard(
                              _filteredTempahan()[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class PaparanTempahanPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const PaparanTempahanPage({super.key, required this.item});

  void exportToPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: item.entries.map((e) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${e.key}: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Expanded(child: pw.Text(e.value.toString())),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'tempahan_${item['tarikh_bertolak'] ?? 'dokumen'}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maklumat Tempahan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => exportToPdf(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: item.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${e.key}: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Text(e.value.toString())),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
