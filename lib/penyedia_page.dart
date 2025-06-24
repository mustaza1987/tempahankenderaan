import 'package:flutter/material.dart';

class PenyediaPage extends StatelessWidget {
  const PenyediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Penyedia')),
      body: const Center(child: Text('Selamat datang, Penyedia')),
    );
  }
}
