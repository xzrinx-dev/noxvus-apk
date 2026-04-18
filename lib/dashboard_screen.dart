import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  const DashboardScreen({super.key, required this.name});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _clockTimer;
  String _time = '';
  String _date = '';
  String _tz = '';

  String _temp = '--';
  String _desc = '--';
  String _city = '--';
  IconData _weatherIcon = Icons.wb_sunny_rounded;

  int _quoteIdx = 0;
  double _quoteOpacity = 1.0;
  late Timer _quoteTimer;

  final List<Map<String, String>> _quotes = [
    {'text': 'Jangan hitung hari-harimu, buat hari-harimu terhitung.', 'author': 'Muhammad Ali'},
    {'text': 'Sukses bukan kunci kebahagiaan. Kebahagiaan adalah kunci sukses.', 'author': 'Albert Schweitzer'},
    {'text': 'Cara terbaik untuk memulai adalah berhenti bicara dan mulai melakukan.', 'author': 'Walt Disney'},
    {'text': 'Jika lo bisa bermimpi, lo bisa melakukannya.', 'author': 'Walt Disney'},
    {'text': 'Percaya pada diri sendiri adalah rahasia pertama kesuksesan.', 'author': 'Ralph Waldo Emerson'},
    {'text': 'Setiap ahli dulunya pernah jadi pemula.', 'author': 'Helen Hayes'},
    {'text': 'Jangan takut gagal. Takutlah untuk tidak mencoba.', 'author': 'Roy T. Bennett'},
    {'text': 'Kesempatan tidak datang, dia diciptakan.', 'author': 'Chris Grosser'},
    {'text': 'Satu-satunya cara melakukan pekerjaan hebat adalah mencintai apa yang lo kerjakan.', 'author': 'Steve Jobs'},
    {'text': 'Hidup itu 10% apa yang terjadi padamu dan 90% bagaimana kamu meresponsnya.', 'author': 'Charles Swindoll'},
  ];

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadWeather();
    _startQuotes();
  }

  void _startClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _time = DateFormat('HH:mm:ss').format(now);
      _date = DateFormat('EEEE, d MMMM yyyy', 'id').format(now).toUpperCase();
      _tz = now.timeZoneName;
    });
  }

  void _startQuotes() {
    _quoteIdx = DateTime.now().millisecond % _quotes.length;
    _quoteTimer = Timer.periodic(const Duration(seconds: 7), (_) async {
      setState(() => _quoteOpacity = 0);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _quoteIdx = (_quoteIdx + 1) % _quotes.length;
        _quoteOpacity = 1;
      });
    });
  }

  Future<void> _loadWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final weatherRes = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${pos.latitude}&longitude=${pos.longitude}&current_weather=true',
      ));
      final geoRes = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json',
      ));
      if (weatherRes.statusCode == 200 && geoRes.statusCode == 200) {
        final w = json.decode(weatherRes.body);
        final g = json.decode(geoRes.body);
        final cw = w['current_weather'];
        final code = cw['weathercode'] as int;
        if (!mounted) return;
        setState(() {
          _temp = '${cw['temperature']}°';
          _desc = _weatherDesc(code);
          _weatherIcon = _weatherIconData(code);
          _city = g['address']?['city'] ?? g['address']?['town'] ?? g['address']?['county'] ?? 'Lokasi';
        });
      }
    } catch (_) {}
  }

  String _weatherDesc(int code) {
    const m = {0: 'Cerah', 1: 'Cerah Berawan', 2: 'Berawan', 3: 'Mendung',
      45: 'Berkabut', 51: 'Gerimis', 61: 'Hujan', 71: 'Salju', 80: 'Hujan Lokal', 95: 'Badai'};
    return m[code] ?? '--';
  }

  IconData _weatherIconData(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45) return Icons.foggy;
    if (code <= 67) return Icons.grain_rounded;
    if (code <= 77) return Icons.ac_unit_rounded;
    return Icons.thunderstorm_rounded;
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _quoteTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://o.uguu.se/BTTYrSGR.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.65),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _buildWeatherWidget()),
              const SizedBox(width: 14),
              Expanded(child: _buildMusicWidget()),
            ]),
            const SizedBox(height: 14),
            _buildClockCard(),
            const SizedBox(height: 14),
            _buildQuoteCard(),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NoxTheme.radius),
        border: Border.all(color: NoxTheme.border),
        image: const DecorationImage(
          image: NetworkImage('https://o.uguu.se/BTTYrSGR.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NoxTheme.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HEY, ${widget.name.toUpperCase()}',
              style: const TextStyle(color: Colors.white, fontSize: 28,
                fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1)),
            const SizedBox(height: 6),
            Text('NOXVUS TOOLS PLATFORM · @XZRINX',
              style: TextStyle(color: Colors.white.withOpacity(0.4),
                fontSize: 10, fontFamily: 'monospace', letterSpacing: 2)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: NoxTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CUACA', style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          Icon(_weatherIcon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(_temp, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1)),
          Text(_desc, style: TextStyle(color: NoxTheme.text2, fontSize: 11, fontFamily: 'monospace')),
          Text(_city, style: TextStyle(color: NoxTheme.muted, fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildMusicWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: NoxTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MUSIC', style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          const Text('Belum ada lagu', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          Text('Tambah di kode', style: TextStyle(color: NoxTheme.text2, fontSize: 11, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          Row(children: [
            _musicBtn(Icons.skip_previous_rounded),
            const SizedBox(width: 8),
            _musicBtn(Icons.play_arrow_rounded),
            const SizedBox(width: 8),
            _musicBtn(Icons.skip_next_rounded),
          ]),
        ],
      ),
    );
  }

  Widget _musicBtn(IconData icon) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: NoxTheme.bg3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NoxTheme.border),
      ),
      child: Icon(icon, color: NoxTheme.text2, size: 16),
    );
  }

  Widget _buildClockCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: NoxTheme.cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: NoxTheme.accentDim, size: 24),
          const SizedBox(width: 14),
          Text(_time, style: const TextStyle(color: Colors.white, fontSize: 32,
            fontWeight: FontWeight.w800, letterSpacing: -1, height: 1)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_date, style: TextStyle(color: NoxTheme.text2, fontSize: 9, fontFamily: 'monospace')),
              const SizedBox(height: 4),
              Text(_tz, style: TextStyle(color: NoxTheme.muted, fontSize: 9, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    final q = _quotes[_quoteIdx];
    return AnimatedOpacity(
      opacity: _quoteOpacity,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: NoxTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded, color: NoxTheme.muted, size: 24),
            const SizedBox(height: 10),
            Text('"${q['text']!}"', style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.6)),
            const SizedBox(height: 10),
            Text('— ${q['author']!}', style: TextStyle(
              color: NoxTheme.accentDim, fontSize: 11, fontFamily: 'monospace', letterSpacing: 1)),
            const SizedBox(height: 14),
            Row(
              children: List.generate(_quotes.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == _quoteIdx ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i == _quoteIdx ? NoxTheme.accentDim : NoxTheme.muted,
                  borderRadius: BorderRadius.circular(99),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}