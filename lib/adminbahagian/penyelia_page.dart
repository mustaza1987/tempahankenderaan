import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:tempahkenderaan/profil_pengguna.dart';
import 'butiran_tempahan_penyelia.dart';
import 'sejarah_tempahan_admin.dart';
import 'borang_tempahan.dart';
import 'borang_tempahan_page.dart';

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
  Timer? _refreshTimer;
  int _refreshCountdown = 100; // 5 menit dalam detik

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_refreshCountdown > 0) {
          _refreshCountdown--;
        } else {
          _refreshCountdown = 300;
          _refreshData();
        }
      });
    });
  }

  Future<void> _refreshData() async {
    try {
      await fetchTempahan();
      _showSuccessSnackbar('Data telah dikemas kini');
    } catch (e) {
      _showErrorSnackbar('Gagal mengemas kini data: $e');
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([fetchTempahan(), fetchBahagian()]);
    } catch (e) {
      _showErrorSnackbar('Gagal memuat data awal: $e');
    }
  }

  Future<void> fetchBahagian() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_bahagian.php',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          senaraiBahagian = result['senarai'] ?? [];
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memuat senarai bahagian: $e');
      rethrow;
    }
  }

  Future<void> fetchTempahan() async {
    setState(() => isLoading = true);

    try {
      final idBahagian = widget.penyelia['id_bahagian'];
      final response = await http
          .get(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/semak_tempahan.php?id_bahagian=$idBahagian',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          senaraiTempahan = result['senarai'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar('Gagal memuat data tempahan: $e');
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

  void onBottomNavTapped(int index) {
    if (index == 4) {
      _showLogoutDialog();
      return;
    }

    setState(() => selectedIndex = index);
  }

  void _showLogoutDialog() {
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
  }

  Widget _buildWelcomeCard() {
    return Container(
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
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
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
    );
  }

  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildBahagianCard() {
    return Container(
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
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildmenuTempahanKhas() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BorangTempahanPageNew(
              userData: {
                'id_pengguna': widget.penyelia['id_pengguna'] ?? 0,
                'id_bahagian': widget.penyelia['id_bahagian'] ?? 0,
                'nama': widget.penyelia['nama'] ?? 'Penyelia',
              },
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon animasi kereta
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 18),
            // Teks kiri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Permohonan Khas",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(int jumlahBelum) {
    if (jumlahBelum <= 0) return const SizedBox();

    return GestureDetector(
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
            const Icon(Icons.notification_important, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Terdapat $jumlahBelum tempahan baharu yang belum disemak!",
                style: GoogleFonts.poppins(color: Colors.red.shade900),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    int jumlahLulus = senaraiTempahan
        .where((e) => e['status_tempahan'] == 'Lulus')
        .length;
    int jumlahTolak = senaraiTempahan
        .where((e) => e['status_tempahan'] == 'Tolak')
        .length;
    int jumlahBelum = senaraiTempahan
        .where(
          (e) => e['status_tempahan'] == null || e['status_tempahan'] == 'Baru',
        )
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildBahagianCard(),
          const SizedBox(height: 20),
          _buildmenuTempahanKhas(),
          const SizedBox(height: 20),
          _buildNotificationCard(jumlahBelum),
          const SizedBox(height: 20),
          _buildStatisticsCard(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
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
            child: _RingkasanBarChart(
              idBahagian:
                  int.tryParse(widget.penyelia['id_bahagian'].toString()) ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempahanList() {
    if (senaraiTempahan.isEmpty) {
      return const Center(child: Text("Tiada tempahan untuk disemak"));
    }

    return ListView.builder(
      itemCount: senaraiTempahan.length,
      itemBuilder: (context, index) {
        final tempahan = senaraiTempahan[index];
        final idBahagianPemohon = tempahan['id_bahagian']?.toString();
        final bool showBkpOption = idBahagianPemohon != '1';

        return Card(
          color:
              (tempahan['status_tempahan'] == null ||
                  tempahan['status_tempahan'] == 'Baru')
              ? const Color.fromARGB(255, 255, 252, 215)
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ButiranTempahanPenyelia(tempahan: tempahan),
                ),
              ).then((refresh) {
                if (refresh == true) {
                  fetchTempahan();
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget getBodyContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildTempahanList();
      case 2:
        return SejarahTempahanPage(idBahagian: widget.penyelia['id_bahagian']);
      case 3:
        return ProfilPenggunaPage(user: widget.penyelia);

      default:
        return const Center(child: Text("Halaman tidak dijumpai"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Penyelia"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshCountdown = 300;
              _refreshData();
            },
            tooltip: 'Refresh data',
          ),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Sejarah'),
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

class _RingkasanBarChart extends StatefulWidget {
  final int idBahagian;

  const _RingkasanBarChart({super.key, required this.idBahagian});

  @override
  State<_RingkasanBarChart> createState() => _RingkasanBarChartState();
}

class _RingkasanBarChartState extends State<_RingkasanBarChart> {
  Map<String, int> dataStatus = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRingkasan();
  }

  Future<void> fetchRingkasan() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/get_ringkasan_status.php?id_bahagian=${widget.idBahagian}',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // Filter hanya status Lulus dan Tolak
        final filteredData = Map<String, int>.from(result)
          ..removeWhere(
            (key, value) => !['lulus', 'tolak'].contains(key.toLowerCase()),
          );

        setState(() {
          dataStatus = filteredData;
          loading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() => loading = false);
      rethrow;
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

    if (dataStatus.isEmpty) {
      return const Center(child: Text("Tiada data untuk carta bar."));
    }

    final maxValue = dataStatus.values.reduce((a, b) => a > b ? a : b);
    final entries = dataStatus.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue.toDouble() * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.grey.shade800,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final status = entries[groupIndex].key;
                    final value = entries[groupIndex].value;
                    final total = dataStatus.values.fold(0, (a, b) => a + b);
                    final percentage = total > 0
                        ? (value / total * 100).toStringAsFixed(1)
                        : '0.0';

                    return BarTooltipItem(
                      '$status\n$value ($percentage%)',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            entries[index].key,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: GoogleFonts.poppins(fontSize: 10),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              barGroups: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final warna = _getStatusColor(data.key);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.value.toDouble(),
                      color: warna,
                      width: 30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: dataStatus.entries.map((entry) {
            final warna = _getStatusColor(entry.key);
            return _legendWarna(warna, '${entry.key} (${entry.value})');
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lulus':
        return Colors.green;
      case 'tolak':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
