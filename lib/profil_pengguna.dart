import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilPenggunaPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfilPenggunaPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String noKp = user['no_kad_pengenalan'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user['nama'] ?? 'Nama tidak tersedia',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          buildInfoTile('No Kad Pengenalan', noKp),
          buildInfoTile('Emel', user['emel']),
          buildInfoTile('No Telefon Pejabat', user['no_telefon_pejabat']),
          buildInfoTile('No Telefon Bimbit', user['no_telefon_bimbit']),
          buildInfoTile('Jawatan', user['jawatan']),
          buildInfoTile('Gred', user['gred']),
          buildInfoTile('Skim', user['skim']),
          buildInfoTile('Bahagian', user['nama_bahagian']),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
            onPressed: () {
              final url = Uri.parse(
                'https://tempahanfasiliti.perak.gov.my/fasiliti/profile.php?id=$noKp',
              );
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  Widget buildInfoTile(String label, dynamic value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value?.toString() ?? 'Tiada maklumat'),
        leading: const Icon(Icons.info_outline),
      ),
    );
  }
}
