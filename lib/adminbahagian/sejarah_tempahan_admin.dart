import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SejarahTempahanPage extends StatefulWidget {
  final dynamic idBahagian;

  const SejarahTempahanPage({super.key, required this.idBahagian});

  @override
  State<SejarahTempahanPage> createState() => _SejarahTempahanPageState();
}

class _SejarahTempahanPageState extends State<SejarahTempahanPage> {
  bool isLoading = true;
  List<dynamic> senaraiSejarah = [];
  List<dynamic> senaraiStatus = [];
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchStatusOptions();
    fetchSejarahTempahan();
  }

  Future<void> fetchStatusOptions() async {
    try {
      setState(() {
        senaraiStatus = [
          {'id': null, 'nama': 'Semua Status'},
          {'id': '1', 'nama': 'Baru'},
          {'id': '2', 'nama': 'Lulus'},
          {'id': '3', 'nama': 'Tidak Lulus'},
          {'id': '6', 'nama': 'Batal'},
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ralat: $e')));
    }
  }

  Future<void> fetchSejarahTempahan() async {
    try {
      setState(() => isLoading = true);

      String url =
          'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/sejarah_tempahan_admin.php?id_bahagian=${widget.idBahagian}';

      if (selectedStatus != null) {
        url += '&status=$selectedStatus';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          senaraiSejarah = result['senarai'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal ambil data sejarah tempahan')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ralat: $e')));
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

  String _formatMasa(String? masa) {
    if (masa == null || masa.isEmpty) return '';
    return masa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tapisan
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Tapisan Status',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() => selectedStatus = null);
                    fetchSejarahTempahan();
                  },
                ),
              ),
              items: senaraiStatus.map<DropdownMenuItem<String>>((status) {
                return DropdownMenuItem<String>(
                  value: status['id'],
                  child: Text(status['nama']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedStatus = value);
                fetchSejarahTempahan();
              },
            ),
          ),

          // Statistik
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Jumlah Rekod: ${senaraiSejarah.length}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Senarai Sejarah
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : senaraiSejarah.isEmpty
                ? Center(
                    child: Text(
                      'Tiada rekod sejarah tempahan',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: senaraiSejarah.length,
                    itemBuilder: (context, index) {
                      final tempahan = senaraiSejarah[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            tempahan['nama_pemohon'] ?? 'Tiada Nama',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Destinasi: ${tempahan['destinasi'] ?? '-'}',
                                style: GoogleFonts.poppins(),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${tempahan['status_tempahan'] ?? 'Tiada Status'}',
                                style: GoogleFonts.poppins(
                                  color: _getStatusColor(
                                    tempahan['status_tempahan'],
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bertolak: ${_formatTarikh(tempahan['tarikh_bertolak'])} ${_formatMasa(tempahan['masa_bertolak'])}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                'Kembali: ${_formatTarikh(tempahan['tarikh_balik'])} ${_formatMasa(tempahan['masa_balik'])}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              if (tempahan['nama_pemandu'] != null)
                                Text(
                                  'Pemandu: ${tempahan['nama_pemandu']}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              if (tempahan['no_siri_pendaftaran'] != null)
                                Text(
                                  'Kenderaan: ${tempahan['no_siri_pendaftaran']}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              if (tempahan['bahagian'] != null)
                                Text(
                                  'Bahagian: ${tempahan['bahagian']}',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Icon(
                            _getStatusIcon(tempahan['status_tempahan']),
                            color: _getStatusColor(tempahan['status_tempahan']),
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'lulus':
        return Icons.check_circle;
      case 'tidak lulus': // Tambah kes untuk "Tidak Lulus"
      case 'tolak': // Simpan yang sedia ada untuk keserasian
        return Icons.cancel; // atau Icons.block jika itu yang anda mahu
      case 'batal':
        return Icons.block;
      case 'dipanjangkan ke bkp':
        return Icons.forward;
      default:
        return Icons.history;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'lulus':
        return Colors.green;
      case 'tidak lulus': // Tambah kes untuk "Tidak Lulus"
      case 'tolak': // Simpan yang sedia ada untuk keserasian
        return Colors.red;
      case 'batal':
        return Colors.orange;
      case 'dipanjangkan ke bkp':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
