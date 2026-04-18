import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  const DashboardScreen({super.key, required this.name});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _clockTimer;
  String _time = '00:00:00';
  String _date = '';
  String _tz = '';

  String _temp = '--';
  String _desc = 'Memuat...';
  String _city = '';
  IconData _weatherIcon = Icons.wb_sunny_rounded;

  int _quoteIdx = 0;
  double _quoteOpacity = 1.0;
  late Timer _quoteTimer;

  final _days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
  final _months = ['','Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];

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
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
    _quoteIdx = DateTime.now().millisecond % _quotes.length;
    _quoteTimer = Timer.periodic(const Duration(seconds: 7), (_) async {
      if (!mounted) return;
      setState(() => _quoteOpacity = 0);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() { _quoteIdx = (_quoteIdx + 1) % _quotes.length; _quoteOpacity = 1; });
    });
    _loadWeather();
  }

  void _updateClock() {
    if (!mounted) return;
    final n = DateTime.now();
    final h = n.hour.toString().padLeft(2,'0');
    final m = n.minute.toString().padLeft(2,'0');
    final s = n.second.toString().padLeft(2,'0');
    setState(() {
      _time = '$h:$m:$s';
      _date = '${_days[n.weekday % 7]}, ${n.day} ${_months[n.month]} ${n.year}'.toUpperCase();
      _tz = n.timeZoneName;
    });
  }

  Future<void> _loadWeather() async {
    try {
      final r = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 6));
      if (!mounted) return;
      final g = json.decode(r.body);
      final lat = g['latitude']; final lon = g['longitude'];
      final city = g['city'] ?? '';
      final wr = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true'
      )).timeout(const Duration(seconds: 6));
      if (!mounted) return;
      final w = json.decode(wr.body)['current_weather'];
      final code = (w['weathercode'] as num).toInt();
      setState(() {
        _temp = '${w['temperature']}°C';
        _desc = _wDesc(code);
        _weatherIcon = _wIcon(code);
        _city = city;
      });
    } catch (_) {
      if (mounted) setState(() => _desc = 'Gagal memuat');
    }
  }

  String _wDesc(int c) {
    if (c == 0) return 'Cerah';
    if (c <= 2) return 'Berawan';
    if (c == 3) return 'Mendung';
    if (c <= 67) return 'Hujan';
    return 'Badai';
  }

  IconData _wIcon(int c) {
    if (c == 0) return Icons.wb_sunny_rounded;
    if (c <= 2) return Icons.wb_cloudy_rounded;
    if (c == 3) return Icons.cloud_rounded;
    if (c <= 67) return Icons.grain_rounded;
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
    return Container(
      color: NoxTheme.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _heroCard(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _weatherCard()),
            const SizedBox(width: 12),
            Expanded(child: _musicCard()),
          ]),
          const SizedBox(height: 12),
          _clockCard(),
          const SizedBox(height: 12),
          _quoteCard(),
        ],
      ),
    );
  }

  Widget _heroCard() => Container(
    height: 160,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(NoxTheme.radius),
      border: Border.all(color: NoxTheme.border),
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1C1C1C), Color(0xFF0A0A0A)],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: NoxTheme.border2),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text('NOXVUS · @XZRINX', style: TextStyle(
            color: NoxTheme.accentDim, fontSize: 8, fontFamily: 'monospace', letterSpacing: 2,
          )),
        ),
        const SizedBox(height: 10),
        Text('HEY, ${widget.name.toUpperCase()}', style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5,
        )),
      ],
    ),
  );

  Widget _weatherCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: NoxTheme.card,
      borderRadius: BorderRadius.circular(NoxTheme.radius),
      border: Border.all(color: NoxTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CUACA', style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
      const SizedBox(height: 12),
      Icon(_weatherIcon, color: Colors.white, size: 26),
      const SizedBox(height: 6),
      Text(_temp, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1)),
      const SizedBox(height: 2),
      Text(_desc, style: TextStyle(color: NoxTheme.text2, fontSize: 10, fontFamily: 'monospace')),
      if (_city.isNotEmpty) Text(_city, style: TextStyle(color: NoxTheme.muted, fontSize: 9, fontFamily: 'monospace')),
    ]),
  );

  Widget _musicCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: NoxTheme.card,
      borderRadius: BorderRadius.circular(NoxTheme.radius),
      border: Border.all(color: NoxTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('MUSIK', style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
      const SizedBox(height: 12),
      Text('Berdansalah', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
      Text('Hindia', style: TextStyle(color: NoxTheme.text2, fontSize: 10, fontFamily: 'monospace')),
      const SizedBox(height: 12),
      Row(children: [
        _mBtn(Icons.skip_previous_rounded),
        const SizedBox(width: 8),
        Container(
          width: 34, height: 34,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 8),
        _mBtn(Icons.skip_next_rounded),
      ]),
    ]),
  );

  Widget _mBtn(IconData icon) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      color: NoxTheme.bg3, borderRadius: BorderRadius.circular(8),
      border: Border.all(color: NoxTheme.border),
    ),
    child: Icon(icon, color: NoxTheme.text2, size: 15),
  );

  Widget _clockCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: NoxTheme.card,
      borderRadius: BorderRadius.circular(NoxTheme.radius),
      border: Border.all(color: NoxTheme.border),
    ),
    child: Row(children: [
      Icon(Icons.access_time_rounded, color: NoxTheme.accentDim, size: 20),
      const SizedBox(width: 12),
      Text(_time, style: const TextStyle(
        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800,
        letterSpacing: -1, fontFamily: 'monospace',
      )),
      const Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_date, style: TextStyle(color: NoxTheme.text2, fontSize: 8, fontFamily: 'monospace')),
        const SizedBox(height: 2),
        Text(_tz, style: TextStyle(color: NoxTheme.muted, fontSize: 8, fontFamily: 'monospace')),
      ]),
    ]),
  );

  Widget _quoteCard() {
    final q = _quotes[_quoteIdx];
    return AnimatedOpacity(
      opacity: _quoteOpacity,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NoxTheme.card,
          borderRadius: BorderRadius.circular(NoxTheme.radius),
          border: Border.all(color: NoxTheme.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.format_quote_rounded, color: NoxTheme.muted, size: 20),
          const SizedBox(height: 8),
          Text('"${q['text']!}"', style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.6,
          )),
          const SizedBox(height: 8),
          Text('— ${q['author']!}', style: TextStyle(
            color: NoxTheme.accentDim, fontSize: 10, fontFamily: 'monospace', letterSpacing: 1,
          )),
          const SizedBox(height: 12),
          Row(children: List.generate(_quotes.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: i == _quoteIdx ? 14 : 5, height: 5,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: i == _quoteIdx ? NoxTheme.accentDim : NoxTheme.muted,
              borderRadius: BorderRadius.circular(99),
            ),
          ))),
        ]),
      ),
    );
  }
}
