import 'package:flutter/material.dart';
import 'package:tempahkenderaan/profil_pengguna.dart';
import 'package:tempahkenderaan/tempah_kenderaan_page.dart';

class PenggunaTempahanPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const PenggunaTempahanPage({super.key, required this.user});

  @override
  State<PenggunaTempahanPage> createState() => _PenggunaTempahanPageState();
}

class _PenggunaTempahanPageState extends State<PenggunaTempahanPage> {
  int _selectedIndex = 0;

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
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildWelcomePage() {
    final nama = widget.user['nama'] ?? 'Pengguna';
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang,',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Anda mempunyai 1 tempahan sedang diproses.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset('assets/booking.png', height: 50),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildMenuCard(Icons.history, "Sejarah Tempahan", () {
                  setState(() => _selectedIndex = 1);
                }),
                buildMenuCard(Icons.directions_car, "Tempah Kenderaan", () {
                  setState(() => _selectedIndex = 2);
                }),
                buildMenuCard(Icons.person, "Profil Pengguna", () {
                  setState(() => _selectedIndex = 3);
                }),
                buildMenuCard(Icons.logout, "Log Keluar", () {
                  _onItemTapped(4);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSelected ? 28 : 24,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            isSelected ? label : '',
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.transparent,
              fontWeight: FontWeight.w500,
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
      const CustomPlaceholder(text: 'Sejarah Tempahan'),
      TempahKenderaanPage(user: widget.user),
      ProfilPenggunaPage(user: widget.user),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 2; // Tab tempahan
          });
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        tooltip: 'Tempah Kenderaan',
        child: const Icon(Icons.car_repair_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 20,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.home, 'Menu', 0),
              _buildNavIcon(Icons.history, 'Sejarah', 1),
              const SizedBox(width: 40), // ruang untuk FAB
              _buildNavIcon(Icons.person, 'Profil', 3),
              _buildNavIcon(Icons.logout, 'Keluar', 4),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPlaceholder extends StatelessWidget {
  final String text;
  const CustomPlaceholder({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
