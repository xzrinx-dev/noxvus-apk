import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ctrl = TextEditingController();

  void _login() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nx_name', name);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoxTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'NOX', style: TextStyle(
                    color: Colors.white, fontSize: 52, fontWeight: FontWeight.w800, letterSpacing: -1)),
                  TextSpan(text: 'VUS', style: TextStyle(
                    color: NoxTheme.accentDim, fontSize: 52, fontWeight: FontWeight.w800, letterSpacing: -1)),
                ])),
                const SizedBox(height: 8),
                Text('TOOLS PLATFORM', style: TextStyle(
                  color: NoxTheme.text2, fontSize: 10, letterSpacing: 3, fontFamily: 'monospace')),
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: NoxTheme.card,
                    borderRadius: BorderRadius.circular(NoxTheme.radius),
                    border: Border.all(color: NoxTheme.border2),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('NAMA LO', style: TextStyle(
                      color: NoxTheme.text2, fontSize: 10, letterSpacing: 2, fontFamily: 'monospace')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ctrl,
                      autofocus: true,
                      maxLength: 24,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'nama...',
                        hintStyle: TextStyle(color: NoxTheme.muted),
                        filled: true,
                        fillColor: NoxTheme.bg3,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(NoxTheme.radiusSm),
                          borderSide: BorderSide(color: NoxTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(NoxTheme.radiusSm),
                          borderSide: BorderSide(color: NoxTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(NoxTheme.radiusSm),
                          borderSide: BorderSide(color: NoxTheme.border2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(NoxTheme.radiusSm)),
                          elevation: 0,
                        ),
                        child: const Text('Masuk →', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
