import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

const _bg = Color(0xFF0A0A0A);
const _bg3 = Color(0xFF181818);
const _card = Color(0xFF141414);
const _border = Color(0x12FFFFFF);
const _border2 = Color(0x1FFFFFFF);
const _accentDim = Color(0xFF666666);
const _muted = Color(0xFF3A3A3A);
const _text2 = Color(0xFF888888);
const _radius = 16.0;
const _radiusSm = 10.0;

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
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'NOX', style: TextStyle(
                    color: Colors.white, fontSize: 52,
                    fontWeight: FontWeight.w800, letterSpacing: -1)),
                  TextSpan(text: 'VUS', style: TextStyle(
                    color: _accentDim, fontSize: 52,
                    fontWeight: FontWeight.w800, letterSpacing: -1)),
                ])),
                const SizedBox(height: 8),
                const Text('TOOLS PLATFORM', style: TextStyle(
                  color: _text2, fontSize: 10, letterSpacing: 3)),
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(_radius),
                    border: Border.all(color: _border2),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('NAMA LO', style: TextStyle(
                      color: _text2, fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ctrl,
                      autofocus: true,
                      maxLength: 24,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'nama...',
                        hintStyle: const TextStyle(color: _muted),
                        filled: true,
                        fillColor: _bg3,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_radiusSm),
                          borderSide: const BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_radiusSm),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_radiusSm),
                          borderSide: const BorderSide(color: _border2),
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
                            borderRadius: BorderRadius.circular(_radiusSm)),
                          elevation: 0,
                        ),
                        child: const Text('Masuk →',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
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
