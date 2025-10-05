import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ButiranTempahanPemandu extends StatefulWidget {
  final Map<String, dynamic> data;

  const ButiranTempahanPemandu({super.key, required this.data});

  @override
  State<ButiranTempahanPemandu> createState() => _ButiranTempahanPemanduState();
}

class _ButiranTempahanPemanduState extends State<ButiranTempahanPemandu> {
  double? lat;
  double? lng;
  String? lokasiPenuh;

  @override
  void initState() {
    super.initState();
    _initPeta();
  }

  Future<void> _initPeta() async {
    if (widget.data['latitud'] != null && widget.data['longitud'] != null) {
      lat = double.tryParse(widget.data['latitud']);
      lng = double.tryParse(widget.data['longitud']);
    } else {
      final lokasi = widget.data['destinasi'];
      if (lokasi != null && lokasi.toString().isNotEmpty) {
        final RegExp regex = RegExp(r'Lat:\s*([-0-9.]+),\s*Lng:\s*([-0-9.]+)');
        final match = regex.firstMatch(lokasi);
        if (match != null) {
          lat = double.tryParse(match.group(1)!);
          lng = double.tryParse(match.group(2)!);
        } else {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(lokasi)}&format=json&limit=1',
          );
          final res = await http.get(
            url,
            headers: {'User-Agent': 'tempahan-kenderaan-app'},
          );
          if (res.statusCode == 200) {
            final List data = json.decode(res.body);
            if (data.isNotEmpty) {
              lat = double.tryParse(data[0]['lat']);
              lng = double.tryParse(data[0]['lon']);
            }
          }
        }
      }
    }

    if (lat != null && lng != null) {
      final url = Uri.parse(
        'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/reverse_proxy.php?lat=$lat&lon=$lng',
      );
      final res = await http.get(
        url,
        headers: {'User-Agent': 'tempahan-kenderaan-app'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          lokasiPenuh = data['display_name'];
        });
      }
    }

    setState(() {});
  }

  String formatTarikh(String? date) {
    if (date == null || date.isEmpty || date == '0000-00-00') return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final tujuan = data['tujuan'] ?? '-';
    final namapemohon = data['nama_pemohon'] ?? '-';
    final destinasi = data['destinasi'] ?? '-';
    final tarikhBertolak = formatTarikh(data['tarikh_bertolak']);
    final masaBertolak = data['masa_bertolak'] ?? '-';
    final tarikhBalik = formatTarikh(data['tarikh_balik']);
    final masaBalik = data['masa_balik'] ?? '-';
    final kenderaan = data['no_siri_pendaftaran'] ?? '-';
    final bilPenumpang = data['jum_orang'] ?? '-';
    final status = data['status_tempahan'] ?? '-';
    final catatan = data['catatan'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Butiran Tempahan"),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _cetakPDF(context, data),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildRow(" Nama Pemohon", namapemohon),
          _buildRow("🚩 Destinasi", destinasi),
          if (lokasiPenuh != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                lokasiPenuh!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          _buildRow("📌 Tujuan", tujuan),
          _buildRow("🕒 Bertolak", "$tarikhBertolak, $masaBertolak"),
          _buildRow("🕒 Balik", "$tarikhBalik, $masaBalik"),
          _buildRow("🚗 No.Kenderaan", kenderaan),
          _buildRow("👥 Penumpang", bilPenumpang),
          _buildRow("📌 Status", status),
          _buildRow("📝 Catatan", catatan),
          if (lat != null && lng != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🗺 Lokasi di Peta",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(center: LatLng(lat!, lng!), zoom: 15.0),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            point: LatLng(lat!, lng!),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _bukaArah(lat.toString(), lng.toString()),
                    icon: const Icon(Icons.map),
                    label: const Text("Buka Lokasi"),
                  ),
                ),
                const Divider(height: 24),
              ],
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _shareToWhatsApp(context, data),
            icon: const Icon(Icons.share),
            label: const Text("Kongsi melalui WhatsApp"),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
        const Divider(height: 24),
      ],
    );
  }

  Future<void> _cetakPDF(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final pdf = pw.Document();
    final logo = await rootBundle.load('assets/booking.png');
    final logoImage = pw.MemoryImage(logo.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logoImage, width: 80),
              pw.Text(
                "Butiran Tempahan Kenderaan",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 80),
            ],
          ),
          pw.SizedBox(height: 20),
          _pdfRow("Nama Pemohon", data['nama_pemohon']),
          _pdfRow("Destinasi", data['destinasi']),
          _pdfRow("Tujuan", data['tujuan']),
          _pdfRow("Tarikh Bertolak", formatTarikh(data['tarikh_bertolak'])),
          _pdfRow("Masa Bertolak", data['masa_bertolak']),
          _pdfRow("Tarikh Balik", formatTarikh(data['tarikh_balik'])),
          _pdfRow("Masa Balik", data['masa_balik']),
          _pdfRow("No.Kenderaan", data['no_siri_pendaftaran']),
          _pdfRow("Penumpang", data['jum_orang']),
          _pdfRow("Status", data['status_tempahan']),
          _pdfRow("Catatan", data['catatan']),
          pw.SizedBox(height: 30),
          pw.Text("Tandatangan Pemandu: ______________________"),
          pw.SizedBox(height: 30),
          pw.Text("Disahkan oleh: _____________________________"),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfRow(String label, dynamic value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("$label:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value?.toString() ?? '-'),
        pw.SizedBox(height: 12),
      ],
    );
  }

  void _shareToWhatsApp(BuildContext context, Map<String, dynamic> data) {
    final namapemohon = data['nama_pemohon'] ?? '-';
    final destinasi = data['destinasi'] ?? '-';
    final tujuan = data['tujuan'] ?? '-';
    final tarikh = formatTarikh(data['tarikh_bertolak']);
    final masaBertolak = data['masa_bertolak'] ?? '-';
    final kenderaan = data['no_siri_pendaftaran'] ?? '-';
    final msg =
        '''
Tempahan Kenderaan 📄

Nama Pemohon :$namapemohon
Destinasi: $destinasi
🚗 No.Kenderaan: $kenderaan
🚩 Tujuan: $tujuan
🕒 Tarikh: $tarikh
🕒 Masa Bertolak: $masaBertolak
📌 Status: ${data['status_tempahan']}

-- Dihantar dari Aplikasi Tempahan --
''';

    Share.share(msg);
  }

  void _bukaArah(String? lat, String? lng) async {
    if (lat == null || lng == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
