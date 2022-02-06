import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:menu/controller/database_controller.dart';
import 'package:menu/view/onboarding_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'model/user.dart' as my;
import 'view/home_screen.dart';
import 'view/login_form.dart';

final supabase = Supabase.instance.client;
late final FlutterSecureStorage storage;
late final DatabaseController dbController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'],
    anonKey: dotenv.env['ANON_KEY'],
    debug: kDebugMode,
  );
  storage = const FlutterSecureStorage();
  dbController = DatabaseController();

  storage.write(key: 'user_onboard', value: null);
  runApp(const ProviderScope(child: MenuApp()));
}

class MenuApp extends StatelessWidget {
  const MenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(
        child: FutureBuilder<my.User?>(
          future: dbController.getUserDataFromDisk(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data!.onboard) {
                return HomeScreen(user: snapshot.data!);
              } else {
                final controller = PageController(
                  initialPage: 0,
                );
                return Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: controller,
                      children: [
                        LoginForm(controller),
                        OnboardingForm(controller),
                      ],
                    ),
                  ),
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class Token extends StatelessWidget {
  const Token({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      width: 260,
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: Column(
        children: [
          Text(
            '7 verbleibende Menü-Bons',
            style: TextStyle(color: Colors.red[900]),
          ),
          const SizedBox(height: 16),
          const Text(
            'MENÜ-BON',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          QrImage(
            data: "askldhajkhsdkjha",
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 16),
          const Text(
            'Vegan',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}
