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
  late Timer _quoteTimer;
  String _time = '00:00:00';
  String _date = '';
  String _tz = '';
  String _temp = '--';
  String _desc = 'Memuat...';
  String _city = '';
  IconData _weatherIcon = Icons.wb_sunny_rounded;
  int _quoteIdx = 0;
  double _quoteOpacity = 1.0;

  static const _days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
  static const _months = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

  static const _quotes = [
    ['Jangan hitung hari-harimu, buat hari-harimu terhitung.', 'Muhammad Ali'],
    ['Sukses bukan kunci kebahagiaan. Kebahagiaan adalah kunci sukses.', 'Albert Schweitzer'],
    ['Cara terbaik untuk memulai adalah berhenti bicara dan mulai melakukan.', 'Walt Disney'],
    ['Jika lo bisa bermimpi, lo bisa melakukannya.', 'Walt Disney'],
    ['Percaya pada diri sendiri adalah rahasia pertama kesuksesan.', 'Ralph Waldo Emerson'],
    ['Setiap ahli dulunya pernah jadi pemula.', 'Helen Hayes'],
    ['Jangan takut gagal. Takutlah untuk tidak mencoba.', 'Roy T. Bennett'],
    ['Kesempatan tidak datang, dia diciptakan.', 'Chris Grosser'],
    ['Satu-satunya cara melakukan pekerjaan hebat adalah mencintai apa yang lo kerjakan.', 'Steve Jobs'],
    ['Hidup itu 10% apa yang terjadi padamu dan 90% bagaimana kamu meresponsnya.', 'Charles Swindoll'],
  ];

  @override
  void initState() {
    super.initState();
    _tick();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _quoteIdx = DateTime.now().millisecond % _quotes.length;
    _quoteTimer = Timer.periodic(const Duration(seconds: 7), (_) => _nextQuote());
    _weather();
  }

  void _tick() {
    if (!mounted) return;
    final n = DateTime.now();
    setState(() {
      _time = '${_p(n.hour)}:${_p(n.minute)}:${_p(n.second)}';
      _date = '${_days[n.weekday % 7]}, ${n.day} ${_months[n.month]} ${n.year}';
      _tz = n.timeZoneName;
    });
  }

  String _p(int v) => v.toString().padLeft(2, '0');

  void _nextQuote() async {
    if (!mounted) return;
    setState(() => _quoteOpacity = 0);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() { _quoteIdx = (_quoteIdx + 1) % _quotes.length; _quoteOpacity = 1; });
  }

  Future<void> _weather() async {
    try {
      final r = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final g = json.decode(r.body);
      final lat = g['latitude']; final lon = g['longitude'];
      final c = g['city'] ?? '';
      final wr = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true'
      )).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final cw = json.decode(wr.body)['current_weather'];
      final code = (cw['weathercode'] as num).toInt();
      setState(() {
        _temp = '${cw['temperature']}°';
        _desc = _wDesc(code);
        _weatherIcon = _wIcon(code);
        _city = c;
      });
    } catch (_) {
      if (mounted) setState(() { _temp = '--'; _desc = 'Tidak tersedia'; });
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
          _hero(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _weatherCard()),
            const SizedBox(width: 12),
            Expanded(child: _musicCard()),
          ]),
          const SizedBox(height: 12),
          _clock(),
          const SizedBox(height: 12),
          _quote(),
        ],
      ),
    );
  }

  Widget _card({required Widget child, double r = NoxTheme.radius}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: NoxTheme.card,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: NoxTheme.border),
    ),
    child: child,
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
  );

  Widget _hero() => Container(
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
            color: NoxTheme.accentDim, fontSize: 8, fontFamily: 'monospace', letterSpacing: 2)),
        ),
        const SizedBox(height: 10),
        Text('HEY, ${widget.name.toUpperCase()}', style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      ],
    ),
  );

  Widget _weatherCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('CUACA'),
      Icon(_weatherIcon, color: Colors.white, size: 26),
      const SizedBox(height: 6),
      Text(_temp, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1)),
      const SizedBox(height: 2),
      Text(_desc, style: TextStyle(color: NoxTheme.text2, fontSize: 10)),
      if (_city.isNotEmpty) Text(_city, style: TextStyle(color: NoxTheme.muted, fontSize: 9)),
    ],
  ));

  Widget _musicCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('MUSIK'),
      Text('Berdansalah', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        overflow: TextOverflow.ellipsis),
      Text('Hindia', style: TextStyle(color: NoxTheme.text2, fontSize: 10)),
      const SizedBox(height: 12),
      Row(children: [
        _mb(Icons.skip_previous_rounded),
        const SizedBox(width: 8),
        Container(width: 34, height: 34,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20)),
        const SizedBox(width: 8),
        _mb(Icons.skip_next_rounded),
      ]),
    ],
  ));

  Widget _mb(IconData i) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: NoxTheme.bg3, borderRadius: BorderRadius.circular(8), border: Border.all(color: NoxTheme.border)),
    child: Icon(i, color: NoxTheme.text2, size: 15),
  );

  Widget _clock() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(color: NoxTheme.card, borderRadius: BorderRadius.circular(NoxTheme.radius), border: Border.all(color: NoxTheme.border)),
    child: Row(children: [
      Icon(Icons.access_time_rounded, color: NoxTheme.accentDim, size: 20),
      const SizedBox(width: 12),
      Text(_time, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1, fontFamily: 'monospace')),
      const Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_date, style: TextStyle(color: NoxTheme.text2, fontSize: 8)),
        const SizedBox(height: 2),
        Text(_tz, style: TextStyle(color: NoxTheme.muted, fontSize: 8, fontFamily: 'monospace')),
      ]),
    ]),
  );

  Widget _quote() {
    final q = _quotes[_quoteIdx];
    return AnimatedOpacity(
      opacity: _quoteOpacity,
      duration: const Duration(milliseconds: 400),
      child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.format_quote_rounded, color: NoxTheme.muted, size: 20),
        const SizedBox(height: 8),
        Text('"${q[0]}"', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.6)),
        const SizedBox(height: 8),
        Text('— ${q[1]}', style: TextStyle(color: NoxTheme.accentDim, fontSize: 10, fontFamily: 'monospace', letterSpacing: 1)),
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
      ])),
    );
  }
}
