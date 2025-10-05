import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ButiranTempahanPenyelia extends StatefulWidget {
  final Map<String, dynamic> tempahan;

  const ButiranTempahanPenyelia({super.key, required this.tempahan});

  @override
  State<ButiranTempahanPenyelia> createState() =>
      _ButiranTempahanPenyeliaState();
}

class _ButiranTempahanPenyeliaState extends State<ButiranTempahanPenyelia> {
  bool isLoading = false;
  bool isDataLoaded = false;
  Map<String, dynamic> butiranTempahan = {};

  // Separate loading states for better UX
  bool isLoadingStatus = false;
  bool isLoadingPemandu = false;
  bool isLoadingKenderaan = false;

  List<dynamic> senaraiPemandu = [];
  List<dynamic> senaraiKenderaan = [];
  List<dynamic> senaraiStatus = [];

  String? selectedStatus;
  String? selectedPemandu;
  String? selectedKenderaan;
  TextEditingController catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    fetchDataTambahan();
  }

  void _initializeData() {
    butiranTempahan = widget.tempahan;

    // Initialize with safe values
    selectedStatus = _getSafeValue(butiranTempahan['id_status_tempahan']);
    selectedPemandu = _getSafeValue(butiranTempahan['id_pemandu']);
    selectedKenderaan = _getSafeValue(butiranTempahan['id_kenderaan']);
    catatanController.text = butiranTempahan['catatan_admin'] ?? '';
  }

  String? _getSafeValue(dynamic value) {
    if (value == null || value == '0' || value == 0) {
      return null;
    }
    return value.toString();
  }

  Future<void> fetchDataTambahan() async {
    setState(() {
      isLoadingStatus = true;
      isLoadingPemandu = true;
      isLoadingKenderaan = true;
    });

    try {
      await Future.wait([_fetchStatus(), _fetchPemandu(), _fetchKenderaan()]);

      setState(() => isDataLoaded = true);
    } catch (e) {
      _showErrorSnackbar('Gagal memuat data: $e');
    } finally {
      setState(() {
        isLoadingStatus = false;
        isLoadingPemandu = false;
        isLoadingKenderaan = false;
      });
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_status_tempahan.php',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => senaraiStatus = data['senarai'] ?? []);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memuat status: $e');
      rethrow;
    }
  }

  Future<void> _fetchPemandu() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_pemandu.php?id_bahagian=${butiranTempahan['id_bahagian']}',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => senaraiPemandu = data['senarai'] ?? []);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memuat pemandu: $e');
      rethrow;
    }
  }

  Future<void> _fetchKenderaan() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_kenderaan.php?id_bahagian=${butiranTempahan['id_bahagian']}',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => senaraiKenderaan = data['senarai'] ?? []);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memuat kenderaan: $e');
      rethrow;
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<dynamic> items,
    required bool isLoading,
    required String? value,
    required Function(String?) onChanged,
    required String valueKey,
    required String displayKey,
    bool required = false,
  }) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:'),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      );
    }

    final bool valueExists = items.any(
      (item) => item[valueKey]?.toString() == value,
    );
    final String? safeValue = valueExists ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            'Sila Pilih $label',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ...items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item[valueKey]?.toString(),
            child: Text(item[displayKey]?.toString() ?? 'Tiada Data'),
          );
        }).toList(),
      ],
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? 'Sila pilih $label' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Butiran Tempahan"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Maklumat Pemohon
                  _buildPemohonCard(),
                  const SizedBox(height: 16),
                  // Maklumat Tempahan
                  _buildTempahanCard(),
                  const SizedBox(height: 16),
                  // Kelulusan
                  _buildKelulusanCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildPemohonCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MAKLUMAT PEMOHON',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade800,
              ),
            ),
            const Divider(),
            _buildInfoRow(
              'Nama',
              butiranTempahan['nama_pemohon'] ?? 'Tiada Nama',
            ),
            _buildInfoRow('Jawatan', butiranTempahan['jawatan'] ?? '-'),
            _buildInfoRow('Gred', butiranTempahan['gred'] ?? '-'),
            _buildInfoRow('Bahagian', butiranTempahan['bahagian'] ?? '-'),
            _buildInfoRow(
              'No Telefon',
              butiranTempahan['notel_pejabat'] ?? '-',
            ),
            _buildInfoRow('Emel', butiranTempahan['emel'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildTempahanCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MAKLUMAT TEMPAHAN',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade800,
              ),
            ),
            const Divider(),
            _buildInfoRow(
              'Tarikh Bertolak',
              _formatTarikh(butiranTempahan['tarikh_bertolak']),
            ),
            _buildInfoRow(
              'Masa Bertolak',
              butiranTempahan['masa_bertolak'] ?? '-',
            ),
            _buildInfoRow(
              'Tarikh Balik',
              _formatTarikh(butiranTempahan['tarikh_balik']),
            ),
            _buildInfoRow('Masa Balik', butiranTempahan['masa_balik'] ?? '-'),
            _buildInfoRow('Destinasi', butiranTempahan['destinasi'] ?? '-'),
            _buildInfoRow('Tujuan', butiranTempahan['tujuan'] ?? '-'),
            _buildInfoRow(
              'Bilangan Penumpang',
              butiranTempahan['jum_orang']?.toString() ?? '-',
            ),
            _buildInfoRow(
              'Tempat Lapor Diri',
              butiranTempahan['tempat_lapor_diri'] ?? '-',
            ),
            _buildInfoRow('Catatan', butiranTempahan['catatan_pemohon'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildKelulusanCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KELULUSAN',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade800,
              ),
            ),
            const Divider(),
            _buildDropdown(
              label: 'Status Permohonan',
              items: senaraiStatus,
              isLoading: isLoadingStatus,
              value: selectedStatus,
              onChanged: (value) => setState(() => selectedStatus = value),
              valueKey: 'id_status_tempahan',
              displayKey: 'status_tempahan',
              required: true,
            ),
            const SizedBox(height: 16),
            if (selectedStatus == '2') ...[
              _buildDropdown(
                label: 'Nama Pemandu',
                items: senaraiPemandu,
                isLoading: isLoadingPemandu,
                value: selectedPemandu,
                onChanged: (value) => setState(() => selectedPemandu = value),
                valueKey: 'id_pengguna',
                displayKey: 'nama',
                required: true,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'No Kenderaan',
                items: senaraiKenderaan,
                isLoading: isLoadingKenderaan,
                value: selectedKenderaan,
                onChanged: (value) => setState(() => selectedKenderaan = value),
                valueKey: 'id_kenderaan',
                displayKey: 'no_siri_pendaftaran',
                required: true,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: kemaskiniStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  Future<void> kemaskiniStatus() async {
    if (selectedStatus == null) {
      _showErrorSnackbar('Sila pilih status permohonan');
      return;
    }

    if (selectedStatus == '2') {
      if (selectedPemandu == null) {
        _showErrorSnackbar('Sila pilih pemandu');
        return;
      }
      if (selectedKenderaan == null) {
        _showErrorSnackbar('Sila pilih kenderaan');
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/kemaskini_status_penuh.php',
            ),
            body: {
              'id_tempahan': butiranTempahan['id_tempahan'].toString(),
              'id_status_tempahan': selectedStatus!,
              'id_pemandu': selectedPemandu ?? '',
              'id_kenderaan': selectedKenderaan ?? '',
              'catatan_admin': catatanController.text,
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['berjaya'] == true) {
          _showSuccessSnackbar('Tempahan berjaya dikemaskini');
          Navigator.pop(context, true);
        } else {
          _showErrorSnackbar(result['mesej'] ?? 'Gagal kemaskini tempahan');
        }
      } else {
        _showErrorSnackbar('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Ralat: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _formatTarikh(String? tarikh) {
    if (tarikh == null || tarikh.isEmpty) return 'Tiada Tarikh';
    try {
      final date = DateTime.parse(tarikh);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return tarikh;
    }
  }
}
