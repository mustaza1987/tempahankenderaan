import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BorangTempahanPage extends StatefulWidget {
  final Map<String, dynamic> penyelia;

  const BorangTempahanPage({super.key, required this.penyelia});

  @override
  State<BorangTempahanPage> createState() => _BorangTempahanPageState();
}

class _BorangTempahanPageState extends State<BorangTempahanPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller input
  final TextEditingController destinasi = TextEditingController();
  final TextEditingController tempat = TextEditingController();
  final TextEditingController tujuan = TextEditingController();
  final TextEditingController catatan = TextEditingController();
  final TextEditingController jumlahOrang = TextEditingController();

  // Data dropdown
  List pemohonList = [];
  List asetList = [];

  // Nilai terpilih
  String? selectedPemohon;
  String? selectedAset;

  // Auto isi
  String? namaBahagian;
  String? namaJawatan;
  String? idBahagian;
  String? idJawatan;

  // Tarikh & masa
  DateTime? tarikhBertolak;
  TimeOfDay? masaBertolak;
  DateTime? tarikhBalik;
  TimeOfDay? masaBalik;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  /// Fetch data dropdown dari server
  Future<void> fetchDropdownData() async {
    try {
      // Senarai pemohon ikut bahagian penyelia
      final resPemohon = await http.post(
        Uri.parse(
          'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_pengguna.php',
        ),
        body: {'id_penyelia': widget.penyelia['id_pengguna'].toString()},
      );

      // Senarai aset
      final resAset = await http.get(
        Uri.parse(
          'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_aset.php',
        ),
      );

      if (resPemohon.statusCode == 200 && resAset.statusCode == 200) {
        final dataPemohon = json.decode(resPemohon.body);
        final dataAset = json.decode(resAset.body);

        setState(() {
          pemohonList = dataPemohon['senarai'] ?? [];
          asetList = dataAset['senarai'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data dari pelayan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ralat: $e")));
    }
  }

  /// Bila pemohon dipilih
  void onPemohonSelected(String id) {
    final selected = pemohonList.firstWhere(
      (p) => p['id_pemohon'].toString() == id,
      orElse: () => null,
    );

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ralat: Pemohon tidak dijumpai")),
      );
      return;
    }

    setState(() {
      selectedPemohon = id;
      idBahagian = selected['id_bahagian']?.toString() ?? '';
      idJawatan = selected['id_jawatan']?.toString() ?? '';
      namaBahagian = selected['nama_bahagian'] ?? '';
      namaJawatan = selected['nama_jawatan'] ?? '';
    });
  }

  /// Hantar ke server
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (tarikhBertolak == null || masaBertolak == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila pilih tarikh & masa bertolak")),
      );
      return;
    }

    if (tarikhBalik == null || masaBalik == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila pilih tarikh & masa balik")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/simpan_tempahan.php',
        ),
        body: {
          'id_pemohon': selectedPemohon,
          'id_bahagian': idBahagian,
          'id_jawatan': idJawatan,
          'id_jenis_aset': selectedAset,
          'tujuan': tujuan.text,
          'catatan_pemohon': catatan.text,
          'tempat_lapor_diri': tempat.text,
          'destinasi': destinasi.text,
          'jum_orang': jumlahOrang.text,
          'tarikh_bertolak':
              "${tarikhBertolak!.year}-${tarikhBertolak!.month.toString().padLeft(2, '0')}-${tarikhBertolak!.day.toString().padLeft(2, '0')}",
          'masa_bertolak':
              "${masaBertolak!.hour.toString().padLeft(2, '0')}:${masaBertolak!.minute.toString().padLeft(2, '0')}:00",
          'tarikh_balik':
              "${tarikhBalik!.year}-${tarikhBalik!.month.toString().padLeft(2, '0')}-${tarikhBalik!.day.toString().padLeft(2, '0')}",
          'masa_balik':
              "${masaBalik!.hour.toString().padLeft(2, '0')}:${masaBalik!.minute.toString().padLeft(2, '0')}:00",
          'id_penyelia': widget.penyelia['id_pengguna'].toString(),
        },
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Ralat semasa simpan')),
      );

      if (data['status'] == 'success') {
        destinasi.clear();
        tempat.clear();
        tujuan.clear();
        catatan.clear();
        jumlahOrang.clear();
        setState(() {
          selectedPemohon = null;
          selectedAset = null;
          namaBahagian = null;
          namaJawatan = null;
          tarikhBertolak = null;
          masaBertolak = null;
          tarikhBalik = null;
          masaBalik = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ralat semasa simpan: $e")));
    }
  }

  /// Widget picker tarikh & masa
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
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) onDatePicked(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    date != null
                        ? "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}"
                        : "Pilih tarikh",
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (picked != null) onTimePicked(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time != null
                        ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
                        : "Pilih masa",
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tempahan Khas"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Pemohon"),
                value: selectedPemohon,
                items: pemohonList
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id_pemohon'].toString(),
                        child: Text(item['nama_pemohon']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => onPemohonSelected(val!),
                validator: (val) => val == null ? "Sila pilih pemohon" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: "Bahagian"),
                controller: TextEditingController(text: namaBahagian ?? ''),
              ),
              const SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: "Jawatan"),
                controller: TextEditingController(text: namaJawatan ?? ''),
              ),
              const SizedBox(height: 10),
              buildDateTimePicker(
                label: "Tarikh & Masa Bertolak",
                date: tarikhBertolak,
                onDatePicked: (d) => setState(() => tarikhBertolak = d),
                time: masaBertolak,
                onTimePicked: (t) => setState(() => masaBertolak = t),
              ),
              const SizedBox(height: 10),
              buildDateTimePicker(
                label: "Tarikh & Masa Balik",
                date: tarikhBalik,
                onDatePicked: (d) => setState(() => tarikhBalik = d),
                time: masaBalik,
                onTimePicked: (t) => setState(() => masaBalik = t),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: tempat,
                decoration: const InputDecoration(
                  labelText: "Tempat Lapor Diri",
                ),
                validator: (val) =>
                    val!.isEmpty ? "Sila isi Tempat Lapor Diri" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: destinasi,
                decoration: const InputDecoration(labelText: "Destinasi"),
                validator: (val) => val!.isEmpty ? "Sila isi destinasi" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: tujuan,
                decoration: const InputDecoration(labelText: "Tujuan"),
                validator: (val) => val!.isEmpty ? "Sila isi tujuan" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: jumlahOrang,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah Penumpang",
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Jenis Aset"),
                value: selectedAset,
                items: asetList
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id_jenis_aset'].toString(),
                        child: Text(item['jenis_aset']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedAset = val),
                validator: (val) =>
                    val == null ? "Sila pilih jenis aset" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: catatan,
                decoration: const InputDecoration(labelText: "Catatan"),
                validator: (val) => val!.isEmpty ? "Sila isi catatan" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Hantar Tempahan"),
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
