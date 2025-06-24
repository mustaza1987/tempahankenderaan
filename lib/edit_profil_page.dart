import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _namaController;
  late TextEditingController _telefonController;
  late TextEditingController _emelController;
  String status = '';

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user['nama']);
    _telefonController = TextEditingController(
      text: widget.user['no_telefon_bimbit'],
    );
    _emelController = TextEditingController(text: widget.user['emel']);
  }

  Future<void> _kemaskiniProfil() async {
    final response = await http.post(
      Uri.parse('http://localhost/pelanggan/flutapi/edit_profil.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'no_kad_pengenalan': widget.user['no_kad_pengenalan'],
        'nama': _namaController.text,
        'no_telefon_bimbit': _telefonController.text,
        'emel': _emelController.text,
      }),
    );

    final data = jsonDecode(response.body);
    setState(() {
      status = data['message'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kemaskini Profil"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _telefonController,
              decoration: const InputDecoration(labelText: 'No Telefon Bimbit'),
            ),
            TextField(
              controller: _emelController,
              decoration: const InputDecoration(labelText: 'Emel'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _kemaskiniProfil,
              child: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(status, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
