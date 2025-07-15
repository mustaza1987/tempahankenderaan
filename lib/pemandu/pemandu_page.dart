import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:http/http.dart' as http;
import 'package:eMobilSUK/profil_pengguna.dart';
import 'sejarah_tempahan_pemandu.dart';
import 'butiran_tempahan_pemandu.dart';
import 'package:intl/intl.dart';

class PemanduPage extends StatefulWidget {
  final Map<String, dynamic> pemandu;

  const PemanduPage({super.key, required this.pemandu});

  @override
  State<PemanduPage> createState() => _PemanduPageState();
}

class _PemanduPageState extends State<PemanduPage> {
  int _selectedIndex = 0;
  bool _showImage = false;
  Timer? _pollingTimer;
  int _latestTempahanCount = 0;
  List<dynamic> _senaraiTempahanBaru = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 400), () {
      setState(() => _showImage = true);
    });

    _semakTempahanBaru();
    _mulaPollingSemakanTempahan();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _mulaPollingSemakanTempahan() {
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _semakTempahanBaru();
    });
  }

  void _semakTempahanBaru() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.20.18.184/kenderaanALL/flutapi/semak_tempahan_baru.php?id_pengguna=${widget.pemandu['id_pengguna']}',
        ),
      );

      print('Respons API: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int jumlah = data['jumlah_tempahan'] ?? 0;
        List<dynamic> tempahanBaru = data['senarai'] ?? [];

        print('Jumlah: $jumlah, Senarai: $tempahanBaru');

        setState(() {
          _latestTempahanCount = jumlah;
          _senaraiTempahanBaru = tempahanBaru;
        });

        if (jumlah > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📢 Anda ada tempahan baharu!'),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      }
    } catch (e) {
      print('Ralat semak tempahan baharu: $e');
    }
  }

  Widget _buildHomePage() {
    return Container(
      color: const Color(0xFFF2F5F8),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                      widget.pemandu['nama'] ?? 'Pemandu',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tarikh dikemaskini
            Text(
              'Dikemaskini: ${DateFormat('dd/MM/yyyy hh:mm:ss a').format(DateTime.now())}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            if (_senaraiTempahanBaru.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Ada ${_senaraiTempahanBaru.length} Tempahan Baharu:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              for (var tempahan in _senaraiTempahanBaru)
                Card(
                  color: Colors.lightGreen[50],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.new_releases, color: Colors.green[700]),
                    title: Text(tempahan['destinasi'] ?? 'Destinasi'),
                    subtitle: Text(
                      '${tempahan['tarikh_bertolak']} @ ${tempahan['masa_bertolak']}',
                      style: TextStyle(color: Colors.black54),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ButiranTempahanPemandu(data: tempahan),
                        ),
                      );
                    },
                  ),
                ),
            ] else ...[
              const SizedBox(height: 30),
              Text(
                'Tiada tempahan baharu buat masa ini.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return SejarahTempahanPemandu(
          idPengguna: widget.pemandu['id_pengguna'],
        );
      case 2:
        return ProfilPenggunaPage(user: widget.pemandu);
      default:
        return const SizedBox();
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _tunjukDialogLogout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _tunjukDialogLogout() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Pemandu'),
        backgroundColor: Colors.blue[700],
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
        child: _buildPage(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue[700],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Utama',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Sejarah'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Log Keluar',
          ),
        ],
      ),
    );
  }
}
