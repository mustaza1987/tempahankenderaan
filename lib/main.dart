import 'package:flutter/material.dart';

import 'package:eMobilSUK/pengguna/pengguna_tempahan_page.dart';
import 'package:eMobilSUK/pengurusan_page.dart';
import 'view/login_page.dart';
import 'package:eMobilSUK/pemandu/pemandu_page.dart';
import 'adminbahagian/penyelia_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Tempahan Kenderaan',
      debugShowCheckedModeBanner: false, // ✅ Buang banner debug
      theme: ThemeData(fontFamily: 'Schyler', primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/penyelia': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return PenyeliaPage(penyelia: args);
          } else {
            return const Scaffold(
              body: Center(child: Text("Ralat: Data penyelia tidak dijumpai")),
            );
          }
        },
        '/pengurusan': (context) => const PengurusanPage(),
        '/pengguna_tempahan': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return PenggunaTempahanPage(user: args);
          } else {
            return const Scaffold(
              body: Center(child: Text("Ralat: Data pengguna tidak dijumpai")),
            );
          }
        },
        '/pemandu': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return PemanduPage(pemandu: args);
          } else {
            return const Scaffold(
              body: Center(child: Text("Ralat: Data pemandu tidak dijumpai")),
            );
          }
        },
      },
    );
  }
}
