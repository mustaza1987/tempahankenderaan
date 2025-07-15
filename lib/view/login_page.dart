import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eMobilSUK/pengguna/pengguna_tempahan_page.dart';

import 'package:eMobilSUK/pemandu/pemandu_page.dart';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

Future<bool> isConnectedToInternet() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nokpController = TextEditingController();
  final TextEditingController katalaluanController = TextEditingController();

  bool rememberMe = false;
  bool showPassword = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNokp = prefs.getString('nokp');
    final savedKatalaluan = prefs.getString('katalaluan');
    final savedRemember = prefs.getBool('rememberMe') ?? false;

    if (savedRemember && savedNokp != null && savedKatalaluan != null) {
      setState(() {
        rememberMe = true;
        nokpController.text = savedNokp;
        katalaluanController.text = savedKatalaluan;
      });
    }
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('nokp', nokpController.text);
      await prefs.setString('katalaluan', katalaluanController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('nokp');
      await prefs.remove('katalaluan');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔌 Periksa sambungan Internet
    if (!await isConnectedToInternet()) {
      setState(() {
        errorMessage = 'Tiada sambungan Internet. Sila cuba semula.';
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Sila tunggu...'),
          ],
        ),
      ),
    );

    try {
      final noKp = nokpController.text.trim();
      final plainPassword = katalaluanController.text.trim();

      final response = await http.post(
        Uri.parse(
          'https://kenderaansuk.perak.gov.my/kenderaanALL/flutapi/loginnew.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'no_kad_pengenalan': noKp,
          'katalaluan': plainPassword,
        }),
      );

      print('Response body: ${response.body}');
      print('NO_KP = $noKp');
      print('KATALALUAN = $plainPassword');

      final result = jsonDecode(response.body);

      Navigator.of(context).pop();

      if (result['status'] == 'success') {
        await saveCredentials();
        final user = result['user'];
        final idPeranan = user['id_peranan'].toString();

        switch (idPeranan) {
          case '2':
            Navigator.pushReplacementNamed(context, '/penyedia');
            break;
          case '1':
            Navigator.pushReplacementNamed(
              context,
              '/penyelia',
              arguments: user, // ✅ Hantar data user ke route
            );
            break;

          case '3':
            Navigator.pushReplacementNamed(context, '/pengurusan');
            break;
          case '4':
            Navigator.pushReplacementNamed(context, '/pentadbir');
            break;
          case '5':
            Navigator.pushReplacementNamed(
              context,
              '/pengguna_tempahan',
              arguments: user,
            );
            break;
          case '6':
            Navigator.pushReplacementNamed(
              context,
              '/pemandu',
              arguments: user,
            );
            break;
          default:
            setState(() => errorMessage = 'Peranan tidak dikenali.');
        }
      } else {
        setState(() => errorMessage = result['message']);
      }
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        errorMessage = 'Ralat sambungan atau respons bukan JSON.\n$e';
      });
    }
  }

  void launchLupaKatalaluan() async {
    final url = Uri.parse(
      'https://tempahanfasiliti.perak.gov.my/fasiliti/index.php',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal buka pautan.')));
    }
  }

  void launchDaftarPengguna() async {
    final url = Uri.parse(
      'https://tempahanfasiliti.perak.gov.my/fasiliti/index.php',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal buka pautan daftar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Image.asset('assets/carm.png', height: 80)],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang ke eMobil SUK',
                style: TextStyle(color: Colors.black, fontSize: 18),
                textAlign: TextAlign.left,
              ),
              const Text(
                'Sila log masuk guna no kad pengenalan dan katalaluan yang didaftar di sistem tempahan fasiliti',
                style: TextStyle(color: Colors.black45, fontSize: 12),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nokpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'No Kad Pengenalan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length != 12) {
                    return 'Masukkan 12 digit No KP tanpa dash (-)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: katalaluanController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'Katalaluan',
                  border: const OutlineInputBorder(),

                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan katalaluan'
                    : null,
              ),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) =>
                        setState(() => rememberMe = value ?? false),
                  ),
                  const Text('Ingat Saya'),
                  const Spacer(),
                  TextButton(
                    onPressed: launchLupaKatalaluan,
                    child: const Text('Lupa Katalaluan?'),
                  ),
                ],
              ),
              if (errorMessage != null) ...[
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              ElevatedButton(onPressed: login, child: const Text('Log Masuk')),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: launchDaftarPengguna,
                  child: const Text('Belum ada akaun? Daftar di sini'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
