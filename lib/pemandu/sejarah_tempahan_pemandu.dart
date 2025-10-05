import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'butiran_tempahan_pemandu.dart';

class SejarahTempahanPemandu extends StatefulWidget {
  final int idPengguna;

  const SejarahTempahanPemandu({super.key, required this.idPengguna});

  @override
  State<SejarahTempahanPemandu> createState() => _SejarahTempahanPemanduState();
}

class _SejarahTempahanPemanduState extends State<SejarahTempahanPemandu> {
  late Future<List<Map<String, dynamic>>> _futureTempahan;
  List<Map<String, dynamic>> semuaTempahan = [];

  int? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    _futureTempahan = _fetchSejarahTempahan();
  }

  Future<List<Map<String, dynamic>>> _fetchSejarahTempahan() async {
    final url = Uri.parse(
      'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/sejarah_tempahan_pemandu.php',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_pengguna': widget.idPengguna}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        semuaTempahan = List<Map<String, dynamic>>.from(data['data']);
        return _tapiskan();
      } else {
        throw Exception('Gagal ambil data: ${data['message']}');
      }
    } else {
      throw Exception('Gagal sambung ke server (${response.statusCode})');
    }
  }

  List<Map<String, dynamic>> _tapiskan() {
    return semuaTempahan.where((item) {
      final tarikh = DateTime.tryParse(item['tarikh_bertolak'] ?? '');
      if (tarikh == null) return false;
      return tarikh.month == selectedMonth && tarikh.year == selectedYear;
    }).toList();
  }

  void _pilihTarikh(int bulan, int tahun) {
    setState(() {
      selectedMonth = bulan;
      selectedYear = tahun;
    });
  }

  List<int> get availableYears {
    final years = semuaTempahan
        .map((e) => DateTime.tryParse(e['tarikh_bertolak'] ?? '')?.year)
        .whereType<int>()
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(child: _buildMonthDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildYearDropdown()),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureTempahan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ralat: ${snapshot.error}'));
                }

                final data = _tapiskan();
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Tiada tempahan untuk bulan ini.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final destinasi = item['destinasi'] ?? '-';
                    final tujuan = item['tujuan'] ?? '-';
                    final tarikhBertolak = item['tarikh_bertolak'] ?? '';
                    final masaBertolak = item['masa_bertolak'] ?? '-';
                    final tarikhBalik = item['tarikh_balik'] ?? '-';
                    final masaBalik = item['masa_balik'] ?? '-';

                    final formattedBertolak = tarikhBertolak.isNotEmpty
                        ? DateFormat(
                            'dd MMM yyyy',
                          ).format(DateTime.parse(tarikhBertolak))
                        : '-';

                    final formattedBalik =
                        tarikhBalik.isNotEmpty && tarikhBalik != '0000-00-00'
                        ? DateFormat(
                            'dd MMM yyyy',
                          ).format(DateTime.parse(tarikhBalik))
                        : '-';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "🚩 Destinasi",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(destinasi),
                            const SizedBox(height: 8),
                            Text(
                              "📍 Tujuan",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(tujuan),
                            const SizedBox(height: 8),
                            Text(
                              "🕒 Bertolak",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("$formattedBertolak, $masaBertolak"),
                            const SizedBox(height: 8),
                            Text(
                              "🕒 Balik",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("$formattedBalik, $masaBalik"),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ButiranTempahanPemandu(data: item),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.info_outline),
                                label: Text("Lihat Butiran"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedMonth,
      decoration: const InputDecoration(labelText: 'Bulan'),
      items: List.generate(12, (index) {
        final month = index + 1;
        return DropdownMenuItem(
          value: month,
          child: Text(DateFormat.MMMM().format(DateTime(0, month))),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          _pilihTarikh(value, selectedYear ?? DateTime.now().year);
        }
      },
    );
  }

  Widget _buildYearDropdown() {
    final years = availableYears.isEmpty
        ? [DateTime.now().year]
        : availableYears;

    return DropdownButtonFormField<int>(
      value: selectedYear,
      decoration: const InputDecoration(labelText: 'Tahun'),
      items: years.map((year) {
        return DropdownMenuItem(value: year, child: Text(year.toString()));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          _pilihTarikh(selectedMonth ?? DateTime.now().month, value);
        }
      },
    );
  }
}
