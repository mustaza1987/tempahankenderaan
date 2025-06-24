import 'package:flutter/material.dart';

class PemanduPage extends StatelessWidget {
  const PemanduPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Pemandu')),
      body: const Center(child: Text('Selamat datang, Pemandu')),
    );
  }
}
