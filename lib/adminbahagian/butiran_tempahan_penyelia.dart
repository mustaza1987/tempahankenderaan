import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ButiranTempahanPenyelia extends StatelessWidget {
  final Map<String, dynamic> tempahan;

  const ButiranTempahanPenyelia({super.key, required this.tempahan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Butiran Tempahan"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _info("Pemohon", tempahan['nama_pemohon']),
                  _info("Bahagian", tempahan['bahagian']),
                  _info("Destinasi", tempahan['destinasi']),
                  _info("Tujuan", tempahan['tujuan']),
                  _info(
                    "Tarikh Bertolak",
                    formatTarikh(tempahan['tarikh_bertolak']),
                  ),
                  _info("Masa Bertolak", tempahan['masa_bertolak']),
                  _info("Tarikh Balik", formatTarikh(tempahan['tarikh_balik'])),
                  _info("Masa Balik", tempahan['masa_balik']),
                  _info(
                    "Status",
                    tempahan['status'] ?? 'Baru',
                    highlight: true,
                  ),
                  _info("Catatan", tempahan['catatan']),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Kembali"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue.shade700,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String? value, {bool highlight = false}) {
    final textColor = highlight
        ? (value == "Lulus"
              ? Colors.green
              : value == "Ditolak"
              ? Colors.red
              : Colors.orange)
        : Colors.black;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value ?? "-",
              style: GoogleFonts.poppins(fontSize: 16, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  String formatTarikh(String? tarikhAsal) {
    if (tarikhAsal == null || tarikhAsal.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(tarikhAsal);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return tarikhAsal;
    }
  }
}
