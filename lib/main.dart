import 'package:flutter/material.dart';
import 'package:tempahkenderaan/pemandu_page.dart';
import 'package:tempahkenderaan/pengguna_tempahan_page.dart';
import 'package:tempahkenderaan/pengurusan_page.dart';
import 'package:tempahkenderaan/pentadbir_page.dart';
import 'package:tempahkenderaan/penyedia_page.dart';
import 'package:tempahkenderaan/penyelia_page.dart';
import 'login_page.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/penyedia': (context) => const PenyediaPage(),
        '/penyelia': (context) => const PenyeliaPage(),
        '/pengurusan': (context) => const PengurusanPage(),
        '/pentadbir': (context) => const PentadbirPage(),
        '/pengguna_tempahan': (context) {
          final user =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return PenggunaTempahanPage(user: user);
        },

        '/pemandu': (context) => const PemanduPage(),
      },
    );
  }
}
