import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  const DashboardScreen({super.key, required this.name});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Clock
  late Timer _clockTimer;
  String _time = '';
  String _date = '';
  String _tz = '';

  // Weather
  String _temp = '--';
  String _desc = '--';
  String _city = '--';
  IconData _weatherIcon = Icons.wb_sunny_rounded;
  bool _weatherLoading = true;

  // Quote
  int _quoteIdx = 0;
  double _quoteOpacity = 1.0;
  late Timer _quoteTimer;

  // Music
  final AudioPlayer _player = AudioPlayer();
  int _trackIdx = 0;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  final List<Map<String, String>> _playlist = [
    {'title': 'Berdansalah', 'artist': 'Hindia', 'path': 'assets/audio/berdansalah.m4a'},
    {'title': 'Untuk Apa', 'artist': 'Hindia', 'path': 'assets/audio/untuk_apa.m4a'},
  ];

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
    _initPlayer();
  }

  void _initPlayer() async {
    await _loadTrack(_trackIdx);
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _playing = state.playing);
      if (state.processingState == ProcessingState.completed) {
        _nextTrack();
      }
    });
  }

  Future<void> _loadTrack(int idx) async {
    try {
      await _player.setAsset(_playlist[idx]['path']!);
    } catch (_) {}
  }

  void _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _prevTrack() async {
    setState(() => _trackIdx = (_trackIdx - 1 + _playlist.length) % _playlist.length);
    await _loadTrack(_trackIdx);
    await _player.play();
  }

  void _nextTrack() async {
    setState(() => _trackIdx = (_trackIdx + 1) % _playlist.length);
    await _loadTrack(_trackIdx);
    await _player.play();
  }

  String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    if (mounted) setState(() {
      _time = DateFormat('HH:mm:ss').format(now);
      _date = DateFormat('EEEE, d MMMM yyyy', 'id').format(now).toUpperCase();
      _tz = now.timeZoneName;
    });
  }

  void _startQuotes() {
    _quoteIdx = DateTime.now().millisecond % _quotes.length;
    _quoteTimer = Timer.periodic(const Duration(seconds: 7), (_) async {
      if (mounted) setState(() => _quoteOpacity = 0);
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
      if (!serviceEnabled) { setState(() => _weatherLoading = false); return; }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) { setState(() => _weatherLoading = false); return; }
      }
      final pos = await Geolocator.getCurrentPosition();
      final weatherRes = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${pos.latitude}&longitude=${pos.longitude}&current_weather=true',
      ));
      final geoRes = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json',
      ));
      if (!mounted) return;
      if (weatherRes.statusCode == 200 && geoRes.statusCode == 200) {
        final w = json.decode(weatherRes.body);
        final g = json.decode(geoRes.body);
        final cw = w['current_weather'];
        final code = cw['weathercode'] as int;
        setState(() {
          _temp = '${cw['temperature']}°';
          _desc = _weatherDesc(code);
          _weatherIcon = _weatherIconData(code);
          _city = g['address']?['city'] ?? g['address']?['town'] ?? g['address']?['county'] ?? 'Lokasi';
          _weatherLoading = false;
        });
      }
    } catch (_) { if (mounted) setState(() => _weatherLoading = false); }
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
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A0A0A), Color(0xFF111111), Color(0xFF0D0D0D)],
              ),
            ),
          ),
        ),
        // Grid lines overlay
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter()),
        ),
        // Content
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NoxTheme.radius),
        border: Border.all(color: NoxTheme.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1A1A), const Color(0xFF0A0A0A)],
        ),
      ),
      child: Stack(
        children: [
          // Glow effect
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: NoxTheme.border2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('NOXVUS', style: TextStyle(
                      color: NoxTheme.accentDim, fontSize: 9,
                      fontFamily: 'monospace', letterSpacing: 3,
                    )),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(
                  'HEY, ${widget.name.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 26,
                    fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TOOLS PLATFORM · @XZRINX',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10, fontFamily: 'monospace', letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NoxTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.cloud_rounded, color: NoxTheme.accentDim, size: 12),
            const SizedBox(width: 4),
            Text('CUACA', style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 14),
          if (_weatherLoading)
            SizedBox(
              height: 60,
              child: Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: NoxTheme.muted))),
            )
          else ...[
            Icon(_weatherIcon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(_temp, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1)),
            Text(_desc, style: TextStyle(color: NoxTheme.text2, fontSize: 10, fontFamily: 'monospace')),
            Text(_city, style: TextStyle(color: NoxTheme.muted, fontSize: 9, fontFamily: 'monospace')),
          ],
        ],
      ),
    );
  }

  Widget _buildMusicWidget() {
    final track = _playlist[_trackIdx];
    final progress = _duration.inSeconds > 0 ? _position.inSeconds / _duration.inSeconds : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NoxTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.music_note_rounded, color: NoxTheme.accentDim, size: 12),
            const SizedBox(width: 4),
            Text('MUSIK', style: TextStyle(color: NoxTheme.text2, fontSize: 9, letterSpacing: 2, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 12),
          Text(track['title']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis),
          Text(track['artist']!, style: TextStyle(color: NoxTheme.text2, fontSize: 10, fontFamily: 'monospace')),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: NoxTheme.muted,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 2,
            ),
          ),
          const SizedBox(height: 4),
          Row(children: [
            Text(_fmtDur(_position), style: TextStyle(color: NoxTheme.muted, fontSize: 9, fontFamily: 'monospace')),
            const Spacer(),
            Text(_fmtDur(_duration), style: TextStyle(color: NoxTheme.muted, fontSize: 9, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _musicBtn(Icons.skip_previous_rounded, _prevTrack),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            _musicBtn(Icons.skip_next_rounded, _nextTrack),
          ]),
        ],
      ),
    );
  }

  Widget _musicBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: NoxTheme.bg3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NoxTheme.border),
        ),
        child: Icon(icon, color: NoxTheme.text2, size: 16),
      ),
    );
  }

  Widget _buildClockCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: NoxTheme.cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, color: NoxTheme.accentDim, size: 20),
          const SizedBox(width: 12),
          Text(_time, style: const TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800,
            letterSpacing: -1, height: 1, fontFamily: 'monospace',
          )),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_date, style: TextStyle(color: NoxTheme.text2, fontSize: 8,
                fontFamily: 'monospace', letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(_tz, style: TextStyle(color: NoxTheme.muted, fontSize: 8, fontFamily: 'monospace')),
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
        padding: const EdgeInsets.all(20),
        decoration: NoxTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded, color: NoxTheme.muted, size: 20),
            const SizedBox(height: 8),
            Text('"${q['text']!}"', style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
              height: 1.6, letterSpacing: -0.2,
            )),
            const SizedBox(height: 8),
            Text('— ${q['author']!}', style: TextStyle(
              color: NoxTheme.accentDim, fontSize: 10,
              fontFamily: 'monospace', letterSpacing: 1,
            )),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_quotes.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == _quoteIdx ? 14 : 5,
                height: 5,
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..strokeWidth = 0.5;
    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
