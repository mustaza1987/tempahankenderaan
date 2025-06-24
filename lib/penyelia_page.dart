import 'package:flutter/material.dart';

class PenyeliaPage extends StatelessWidget {
  const PenyeliaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Penyelia')),
      body: const Center(child: Text('Selamat datang, Penyelia')),
    );
  }
}
