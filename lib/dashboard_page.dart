import 'package:flutter/material.dart';
import 'tempah_kenderaan_page.dart';
import 'edit_profil_page.dart'; // pastikan fail ini wujud

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Pengguna"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const Center(
                      child: Text(
                        "Profil Pengguna",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    profileItem("Nama", user['nama']),
                    profileItem(
                      "No. Kad Pengenalan",
                      user['no_kad_pengenalan'],
                    ),
                    profileItem("Jawatan", user['jawatan']),

                    profileItem(
                      "Telefon Bimbit",
                      user['no_telefon_bimbit'] ?? '-',
                    ),
                    profileItem("Emel", user['emel'] ?? '-'),
                    profileItem("Peranan", user['id_peranan'].toString()),
                    profileItem("Status", _statusText(user['id_status'])),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profil'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Tempah Kenderaan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TempahKenderaanPage(user: user),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }

  Widget profileItem(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(flex: 5, child: Text(value)),
          ],
        ),
      ),
    );
  }

  String _statusText(dynamic idStatus) {
    switch (idStatus) {
      case 0:
        return 'Belum Sah';
      case 1:
        return 'Aktif';
      case 2:
        return 'Tidak Aktif';
      default:
        return 'Tidak Diketahui';
    }
  }
}
