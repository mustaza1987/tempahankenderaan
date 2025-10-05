import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:tempahkenderaan/profil_pengguna.dart';
import 'sejarah_tempahan.dart';
import 'tempah_kenderaan_page.dart';

import 'package:tempahkenderaan/papar_map.dart';
import 'dart:ui';

class PenggunaTempahanPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const PenggunaTempahanPage({super.key, required this.user});

  @override
  State<PenggunaTempahanPage> createState() => _PenggunaTempahanPageState();
}

class _PenggunaTempahanPageState extends State<PenggunaTempahanPage> {
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
          "https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_tempahan_baru.php",
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
        return "Dipanjangkan Ke BKP";
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

  Widget buildSenaraiTempahanLulus(List<dynamic> tempahan) {
    final lulusList = tempahan
        .where((item) => item['id_status_tempahan'].toString() == '2')
        .toList();

    if (lulusList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Tiada Maklumat.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lulusList.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['destinasi'] ?? 'Destinasi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.green),
                      onPressed: () {
                        final lokasi = item['destinasi'] ?? '';
                        final koordinat = lokasi.split(',');
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
                                builder: (_) => PaparMapPage(
                                  latitude: lat,
                                  longitude: lng,
                                  lokasi: lokasi,
                                ),
                              ),
                            );
                          }
                        }
                      },
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
                Text("Pemandu: ${item['nama_pemandu'] ?? '-'}"),
                Text("No Kenderaan: ${item['no_kenderaan'] ?? '-'}"),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> cetakTempahanPDF(Map<String, dynamic> item) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
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

              pw.Text("Nama Pemohon: ${widget.user['nama']}"),
              pw.Text("Destinasi: ${item['destinasi']}"),
              pw.Text("Tarikh: ${formatTarikh(item['tarikh'])}"),
              pw.Text("Tempat Lapor Diri: ${item['tempat_lapor']}"),
              pw.Text("Status: ${getStatusText(item['id_status_tempahan'])}"),
              pw.Text("Pemandu: ${item['nama_pemandu']}"),
              pw.Text("No Kenderaan: ${item['no_kenderaan']}"),
              pw.Text(
                "Dicetak pada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
              ),
              pw.Text(
                "Dicetak oleh: ${widget.user['nama']} (${widget.user['jawatan'] ?? ''})",
              ),
            ],
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
                            ? 'Terdapat ${_senaraiTempahan.length} tempahan sedang diproses (sentuh untuk lihat)'
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
                return Card(
                  color: item['id_status_tempahan'].toString() == '1'
                      ? Colors
                            .orange
                            .shade50 // latar oren lembut jika status Batal
                      : item['id_status_tempahan'].toString() == '6'
                      ? Colors
                            .grey
                            .shade400 // latar oren lembut jika status Baru
                      : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: getStatusColor(item['id_status_tempahan']),
                            ),

                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['destinasi'] ?? 'Destinasi',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.map, color: Colors.green),
                              onPressed: () {
                                final lokasi = item['destinasi'] ?? '';
                                final koordinat = lokasi.split(',');
                                if (koordinat.length == 2) {
                                  final lat = double.tryParse(
                                    koordinat[0].replaceAll(
                                      RegExp('[^0-9.-]'),
                                      '',
                                    ),
                                  );
                                  final lng = double.tryParse(
                                    koordinat[1].replaceAll(
                                      RegExp('[^0-9.-]'),
                                      '',
                                    ),
                                  );
                                  if (lat != null && lng != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaparMapPage(
                                          latitude: lat,
                                          longitude: lng,
                                          lokasi: lokasi,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () => cetakTempahanPDF(item),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text("Tarikh: ${formatTarikh(item['tarikh'])}"),
                        Text("Tempat Lapor Diri: ${item['tempat_lapor']}"),
                        Text(
                          "Status: ${getStatusText(item['id_status_tempahan'])}",
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),
            Text(
              "Tempahan Yang Diluluskan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            buildSenaraiTempahanLulus(_senaraiTempahan),
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
      floatingActionButton: _selectedIndex == 2
          ? null
          : Transform.translate(
              offset: const Offset(0, 10), // ↓ turun 20px
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TempahKenderaanPage(user: widget.user),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                elevation: 1,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 35),
              ),
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _selectedIndex == 2
          ? null
          : BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavIcon(Icons.home, 'Utama', 0),
                    _buildNavIcon(Icons.history, 'Sejarah', 1),
                    const SizedBox(width: 2),
                    _buildNavIcon(Icons.person, 'Profil', 3),
                    _buildNavIcon(Icons.logout, 'Keluar', 4),
                  ],
                ),
              ),
            ),
    );
  }
}
