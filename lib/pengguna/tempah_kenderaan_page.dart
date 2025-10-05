import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:tempahkenderaan/pengguna/pengguna_tempahan_page.dart';

class TempahKenderaanPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const TempahKenderaanPage({super.key, required this.user});

  @override
  State<TempahKenderaanPage> createState() => _TempahKenderaanPageState();
}

class _TempahKenderaanPageState extends State<TempahKenderaanPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController destinasiController = TextEditingController();
  TextEditingController tujuanController = TextEditingController();
  TextEditingController jumOrangController = TextEditingController();
  TextEditingController tempatLaporController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  DateTime? tarikhBertolak;
  TimeOfDay? masaBertolak;
  DateTime? tarikhBalik;
  TimeOfDay? masaBalik;

  int? selectedJenisAset;

  bool isSubmitting = false;

  final List<Map<String, dynamic>> jenisAsetList = [
    {"id": 1, "nama": "Kereta"},
    {"id": 2, "nama": "Bas"},
    {"id": 3, "nama": "Van"},
    {"id": 4, "nama": "Lori"},
    {"id": 7, "nama": "Pacuan Empat Roda"},
    {"id": 8, "nama": "MPV"},
  ];

  Widget buildDateTimePicker({
    required String label,
    required DateTime? date,
    required void Function(DateTime) onDatePicked,
    required TimeOfDay? time,
    required void Function(TimeOfDay) onTimePicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: date ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) onDatePicked(picked);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        date != null
                            ? "${date.day}/${date.month}/${date.year}"
                            : "Pilih Tarikh",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: time ?? TimeOfDay.now(),
                    );
                    if (picked != null) onTimePicked(picked);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        time != null ? time.format(context) : "Pilih Masa",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> submitTempahan() async {
    if (!_formKey.currentState!.validate()) return;
    if (tarikhBertolak == null ||
        masaBertolak == null ||
        tarikhBalik == null ||
        masaBalik == null ||
        selectedJenisAset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sila isi semua maklumat termasuk tarikh dan masa."),
        ),
      );
      return;
    }

    final bertolakDateTime = DateTime(
      tarikhBertolak!.year,
      tarikhBertolak!.month,
      tarikhBertolak!.day,
      masaBertolak!.hour,
      masaBertolak!.minute,
    );

    if (bertolakDateTime.isBefore(
      DateTime.now().add(const Duration(days: 3)),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Sila pastikan anda membuat tempahan 3 hari sebelum tarikh bertolak.",
          ),
        ),
      );
      return;
    }

    if (tarikhBalik!.isBefore(tarikhBertolak!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tarikh balik tidak boleh sebelum tarikh bertolak."),
        ),
      );
      return;
    }
    final balikDateTime = DateTime(
      tarikhBalik!.year,
      tarikhBalik!.month,
      tarikhBalik!.day,
      masaBalik!.hour,
      masaBalik!.minute,
    );

    if (balikDateTime.isBefore(bertolakDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tarikh/masa balik tidak boleh sebelum bertolak."),
        ),
      );
      return;
    }

    final data = {
      "id_pemohon": widget.user['id_pengguna'],
      "nama_pemohon": widget.user['nama'],
      "id_jawatan": widget.user['id_jawatan'],
      "id_gred": widget.user['id_gred'],
      "id_skim": widget.user['id_skim'],
      "id_bahagian": widget.user['id_bahagian'],
      "notel_pejabat": widget.user['no_telefon_pejabat'],
      "emel": widget.user['emel'],
      "id_jenis_aset": selectedJenisAset,
      "destinasi": destinasiController.text,
      "lat_destinasi": null,
      "lng_destinasi": null,
      "tujuan": tujuanController.text,
      "jum_orang": int.tryParse(jumOrangController.text) ?? 1,
      "tempat_lapor_diri": tempatLaporController.text,
      "tarikh_bertolak": tarikhBertolak!.toIso8601String().substring(0, 10),
      "masa_bertolak": masaBertolak!.format(context),
      "tarikh_balik": tarikhBalik!.toIso8601String().substring(0, 10),
      "masa_balik": masaBalik!.format(context),
      "catatan_pemohon": catatanController.text,
    };
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sahkan Tempahan"),
        content: const Text("Anda pasti ingin menghantar tempahan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hantar"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => isSubmitting = true);

    final response = await http.post(
      Uri.parse(
        'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/tempahan.php',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    setState(() => isSubmitting = false);

    try {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Tempahan Berjaya'),
            content: const Text('Tempahan anda telah dihantar dan direkodkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PenggunaTempahanPage(user: widget.user),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: ${result['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ralat semasa menyahkod maklum balas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempahan Kenderaan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: destinasiController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Destinasi",
                hintText: "Contoh: Pejabat SUK Perak, Ipoh",
                suffixIcon: Icon(Icons.location_on),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Isi destinasi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: tujuanController,
              decoration: const InputDecoration(
                labelText: "Tujuan",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Isi tujuan' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: jumOrangController,
              decoration: const InputDecoration(
                labelText: "Jumlah Orang",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Isi jumlah orang' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: tempatLaporController,
              decoration: const InputDecoration(
                labelText: "Tempat Lapor Diri",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            buildDateTimePicker(
              label: "Tarikh & Masa Bertolak",
              date: tarikhBertolak,
              onDatePicked: (d) => setState(() => tarikhBertolak = d),
              time: masaBertolak,
              onTimePicked: (t) => setState(() => masaBertolak = t),
            ),
            buildDateTimePicker(
              label: "Tarikh & Masa Balik",
              date: tarikhBalik,
              onDatePicked: (d) => setState(() => tarikhBalik = d),
              time: masaBalik,
              onTimePicked: (t) => setState(() => masaBalik = t),
            ),
            DropdownButtonFormField<int>(
              value: selectedJenisAset,
              decoration: const InputDecoration(
                labelText: "Jenis Kenderaan",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              items: jenisAsetList.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'] as int,
                  child: Text(item['nama'] as String),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedJenisAset = val),
              validator: (val) => val == null ? 'Pilih jenis aset' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: "Catatan (Jika Ada)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: submitTempahan,
                    child: const Text("Hantar Tempahan"),
                  ),
          ],
        ),
      ),
    );
  }
}
