import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:eMobilSUK/profil_pengguna.dart';
import 'package:fl_chart/fl_chart.dart';
import 'butiran_tempahan_penyelia.dart';

class PenyeliaPage extends StatefulWidget {
  final Map<String, dynamic> penyelia;

  const PenyeliaPage({super.key, required this.penyelia});

  @override
  State<PenyeliaPage> createState() => _PenyeliaPageState();
}

class _PenyeliaPageState extends State<PenyeliaPage> {
  int selectedIndex = 0;
  bool isLoading = true;
  List<dynamic> senaraiTempahan = [];
  List<dynamic> senaraiBahagian = [];
  String? selectedBahagian;

  @override
  void initState() {
    super.initState();
    fetchTempahan();
    fetchBahagian();
  }

  Future<void> fetchBahagian() async {
    final response = await http.get(
      Uri.parse(
        'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_bahagian.php',
      ),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        senaraiBahagian = result['senarai'] ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal ambil senarai bahagian')),
      );
    }
  }

  Future<void> semakTempahan(int idTempahan, String status) async {
    final response = await http.post(
      Uri.parse(
        'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/kemaskini_status.php',
      ),
      body: {'id_tempahan': idTempahan.toString(), 'status': status},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['berjaya'] == true) {
        String mesej;

        if (status == 'bkp') {
          mesej = 'Tempahan dipanjangkan ke BKP';
        } else if (status == 'tolak') {
          mesej = 'Tempahan tidak diluluskan';
        } else {
          mesej = 'Tempahan dikemaskini sebagai $status';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mesej)));

        fetchTempahan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal kemaskini status tempahan')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ralat semasa menghantar permintaan')),
      );
    }
  }

  Future<void> fetchTempahan() async {
    final idBahagian = widget.penyelia['id_bahagian'];
    final response = await http.get(
      Uri.parse(
        'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/semak_tempahan.php?id_bahagian=$idBahagian',
      ),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        senaraiTempahan = result['senarai'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal ambil data tempahan')),
      );
    }
  }

  void onBottomNavTapped(int index) {
    if (index == 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Log Keluar"),
          content: const Text("Anda pasti ingin log keluar?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Ya"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  Widget _legendWarna(Color warna, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: warna),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins()),
      ],
    );
  }

  Widget getBodyContent() {
    switch (selectedIndex) {
      case 0:
        int jumlahLulus = senaraiTempahan
            .where((e) => e['status_tempahan'] == 'Lulus')
            .length;
        int jumlahTolak = senaraiTempahan
            .where((e) => e['status_tempahan'] == 'Tolak')
            .length;
        int jumlahBelum = senaraiTempahan
            .where(
              (e) =>
                  e['status_tempahan'] == null ||
                  e['status_tempahan'] == 'Baru',
            )
            .length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // Selamat datang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.penyelia['nama'] ?? 'Penyelia',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bahagian
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.penyelia['nama_bahagian'] ?? '-'}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (jumlahBelum > 0)
                GestureDetector(
                  onTap: () => setState(() => selectedIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade400),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notification_important,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Terdapat $jumlahBelum tempahan baharu yang belum disemak!",
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.red),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Statistik Tempahan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: _RingkasanPieChart(
                        idBahagian:
                            int.tryParse(
                              widget.penyelia['id_bahagian'].toString(),
                            ) ??
                            0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 1:
        return ListView.builder(
          itemCount: senaraiTempahan.length,
          itemBuilder: (context, index) {
            final tempahan = senaraiTempahan[index];
            return Card(
              color:
                  (tempahan['status_tempahan'] == null ||
                      tempahan['status_tempahan'] == 'Baru')
                  ? Colors.yellow.shade50
                  : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  tempahan['nama_pemohon'] ?? 'Tiada Nama',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Destinasi: ${tempahan['destinasi'] ?? '-'}\n'
                  'Status: ${tempahan['status_tempahan'] == null || tempahan['status_tempahan'] == 'Baru' ? 'Baru' : tempahan['status_tempahan']}\n'
                  'Bahagian: ${tempahan['bahagian'] ?? 'Tiada Bahagian'}',
                  style: GoogleFonts.poppins(),
                ),

                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'lulus') {
                      await showDialog(
                        context: context,
                        builder: (context) => DialogLulus(
                          idTempahan:
                              int.tryParse(
                                tempahan['id_tempahan'].toString(),
                              ) ??
                              0,
                          idBahagian:
                              int.tryParse(
                                tempahan['id_bahagian'].toString(),
                              ) ??
                              0,
                          idPengguna:
                              int.tryParse(
                                widget.penyelia['id_pengguna'].toString(),
                              ) ??
                              0,
                          onSelesai: fetchTempahan,
                        ),
                      );
                    } else {
                      await semakTempahan(
                        tempahan['id_tempahan'] is int
                            ? tempahan['id_tempahan']
                            : int.parse(tempahan['id_tempahan'].toString()),
                        value,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'lulus', child: Text('Lulus')),
                    PopupMenuItem(value: 'tolak', child: Text('Tolak')),
                    PopupMenuItem(
                      value: 'bkp',
                      child: Text('Panjangkan ke BKP'),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ButiranTempahanPenyelia(tempahan: tempahan),
                    ),
                  );
                },
              ),
            );
          },
        );

      case 2:
        return ProfilPenggunaPage(user: widget.penyelia);

      default:
        return const Center(child: Text("Halaman tidak dijumpai"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Halaman Penyelia"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : getBodyContent(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onBottomNavTapped,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Tempahan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Log Keluar',
          ),
        ],
      ),
    );
  }
}

class DialogLulus extends StatefulWidget {
  final int idTempahan;
  final int idBahagian;
  final int idPengguna; // ✅ Tambah ini
  final VoidCallback onSelesai;

  const DialogLulus({
    super.key,
    required this.idTempahan,
    required this.idBahagian,
    required this.idPengguna, // ✅ Tambah ini
    required this.onSelesai,
  });

  @override
  State<DialogLulus> createState() => _DialogLulusState();
}

class _DialogLulusState extends State<DialogLulus> {
  String? selectedPemandu;
  String? selectedNoKenderaan;
  List<dynamic> senaraiPemandu = [];
  List<dynamic> senaraiKenderaan = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final resPemandu = await http.get(
      Uri.parse(
        'http://10.20.18.184/kenderaanALL/flutapi/get_pemandu.php?id_bahagian=${widget.idBahagian}',
      ),
    );

    final resKenderaan = await http.get(
      Uri.parse(
        'http://10.20.18.184/kenderaanALL/flutapi/get_kenderaan.php?id_bahagian=${widget.idBahagian}',
      ),
    );

    if (resPemandu.statusCode == 200 && resKenderaan.statusCode == 200) {
      setState(() {
        senaraiPemandu = jsonDecode(resPemandu.body)['senarai'] ?? [];
        senaraiKenderaan = jsonDecode(resKenderaan.body)['senarai'] ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal ambil data pemandu/kenderaan')),
      );
    }
  }

  Future<void> hantarKelulusan() async {
    if (selectedPemandu == null || selectedNoKenderaan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila pilih pemandu dan no kenderaan')),
      );
      return;
    }

    final res = await http.post(
      Uri.parse(
        'http://10.20.18.184/kenderaanALL/flutapi/kemaskini_status.php',
      ),
      body: {
        'id_tempahan': widget.idTempahan.toString(),
        'status': '2', // atau 'lulus'
        'id_pemandu': selectedPemandu!,
        'id_kenderaan': selectedNoKenderaan!,
        'id_pengguna': widget.idPengguna.toString(), // sama dengan PHP
      },
    );

    if (res.statusCode == 200) {
      Navigator.pop(context);
      widget.onSelesai();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempahan berjaya diluluskan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Kelulusan Tempahan"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedPemandu,
            isExpanded: true,
            hint: const Text("Pilih Pemandu"),
            items: senaraiPemandu.map<DropdownMenuItem<String>>((p) {
              return DropdownMenuItem<String>(
                value: p['id_pengguna'].toString(),
                child: Text(p['nama']),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedPemandu = val),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedNoKenderaan,
            isExpanded: true,
            hint: const Text("Pilih No Kenderaan"),
            items: senaraiKenderaan.map<DropdownMenuItem<String>>((k) {
              return DropdownMenuItem<String>(
                value: k['id_kenderaan'].toString(),
                child: Text(k['no_siri_pendaftaran']),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedNoKenderaan = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(onPressed: hantarKelulusan, child: const Text("Sahkan")),
      ],
    );
  }
}

class _RingkasanPieChart extends StatefulWidget {
  final int idBahagian;

  const _RingkasanPieChart({super.key, required this.idBahagian});

  @override
  State<_RingkasanPieChart> createState() => _RingkasanPieChartState();
}

class _RingkasanPieChartState extends State<_RingkasanPieChart> {
  Map<String, int> dataStatus = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRingkasan();
  }

  Future<void> fetchRingkasan() async {
    final response = await http.get(
      Uri.parse(
        'http://10.20.18.184/kenderaanALL/flutapi/get_ringkasan_status.php?id_bahagian=${widget.idBahagian}',
      ),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        dataStatus = Map<String, int>.from(
          result.map((key, value) => MapEntry(key, value as int)),
        );
        loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal ambil statistik carta pai')),
      );
    }
  }

  Widget _legendWarna(Color warna, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: warna),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    int jumlah = dataStatus.values.fold(0, (a, b) => a + b);
    if (jumlah == 0) return const Text("Tiada data untuk carta pai.");

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: dataStatus.entries.map((entry) {
                final warna = switch (entry.key.toLowerCase()) {
                  'lulus' => Colors.green,
                  'tolak' => Colors.red,
                  'baru' => Colors.grey,
                  'batal' => Colors.orange,
                  'dipanjangkan ke bkp' => Colors.purple,
                  _ => Colors.blueGrey,
                };

                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  color: warna,
                  title: '${entry.value}', // contoh: "5"
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: dataStatus.keys.map((status) {
            final warna = switch (status.toLowerCase()) {
              'lulus' => Colors.green,
              'tolak' => Colors.red,
              'baru' => Colors.grey,
              'batal' => Colors.orange,
              'dipanjangkan ke bkp' => Colors.purple,
              _ => Colors.blueGrey,
            };
            return _legendWarna(warna, status);
          }).toList(),
        ),
      ],
    );
  }
}
