import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('nx_name');

  runApp(NoxvusApp(initialName: name));
}

class NoxvusApp extends StatelessWidget {
  final String? initialName;
  const NoxvusApp({super.key, this.initialName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOXVUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0A0A0A),
          primary: Colors.white,
        ),
        fontFamily: 'sans-serif',
      ),
      home: initialName != null
          ? MainScreen(name: initialName!)
          : const LoginScreen(),
    );
  }
}
