import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import '../theme.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const _tools = [
    ['qr', 'QR Code', '0xe3c3'],
    ['password', 'Password', '0xe2fc'],
    ['base64', 'Base64', '0xe059'],
    ['json', 'JSON', '0xe242'],
    ['uuid', 'UUID', '0xe287'],
    ['word', 'Counter', '0xe2ae'],
    ['url', 'URL Encode', '0xe25e'],
    ['hash', 'Hash', '0xe337'],
    ['timestamp', 'Timestamp', '0xf05ab'],
    ['lorem', 'Lorem', '0xe06c'],
    ['case', 'Case', '0xe2af'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NoxTheme.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tools Collection', style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('${_tools.length} tools tersedia', style: TextStyle(color: NoxTheme.text2, fontSize: 11)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: _tools.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => showModalBottomSheet(
                context: ctx,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _ToolModal(id: _tools[i][0]),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: NoxTheme.card,
                  borderRadius: BorderRadius.circular(NoxTheme.radius),
                  border: Border.all(color: NoxTheme.border),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_icons(_tools[i][0]), color: NoxTheme.accentDim, size: 26),
                  const SizedBox(height: 8),
                  Text(_tools[i][1], style: TextStyle(color: NoxTheme.text2, fontSize: 10)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icons(String id) {
    switch (id) {
      case 'qr': return Icons.qr_code_rounded;
      case 'password': return Icons.key_rounded;
      case 'base64': return Icons.swap_horiz_rounded;
      case 'json': return Icons.code_rounded;
      case 'uuid': return Icons.fingerprint_rounded;
      case 'word': return Icons.text_fields_rounded;
      case 'url': return Icons.link_rounded;
      case 'hash': return Icons.lock_rounded;
      case 'timestamp': return Icons.timer_rounded;
      case 'lorem': return Icons.article_rounded;
      case 'case': return Icons.text_format_rounded;
      default: return Icons.build_rounded;
    }
  }
}

class _ToolModal extends StatefulWidget {
  final String id;
  const _ToolModal({required this.id});
  @override
  State<_ToolModal> createState() => _ToolModalState();
}

class _ToolModalState extends State<_ToolModal> {
  final _c1 = TextEditingController();
  String _out = '';
  int _pwLen = 16;
  bool _pwU = true, _pwN = true, _pwS = true;

  String get _title => {
    'qr':'QR Generator','password':'Password Generator','base64':'Base64',
    'json':'JSON Formatter','uuid':'UUID Generator','word':'Word Counter',
    'url':'URL Encode/Decode','hash':'Hash SHA-256','timestamp':'Timestamp',
    'lorem':'Lorem Ipsum','case':'Case Converter',
  }[widget.id] ?? 'Tool';

  void _copy() {
    Clipboard.setData(ClipboardData(text: _out));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1)));
  }

  void _genPW() {
    String c = 'abcdefghijklmnopqrstuvwxyz';
    if (_pwU) c += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_pwN) c += '0123456789';
    if (_pwS) c += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final r = Random.secure();
    setState(() => _out = List.generate(_pwLen, (_) => c[r.nextInt(c.length)]).join());
  }

  void _genUUID() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2,'0')).join();
    setState(() => _out = '${h.substring(0,8)}-${h.substring(8,12)}-${h.substring(12,16)}-${h.substring(16,20)}-${h.substring(20)}');
  }

  void _b64(bool enc) {
    try { setState(() => _out = enc ? base64Encode(utf8.encode(_c1.text)) : utf8.decode(base64Decode(_c1.text))); }
    catch (e) { setState(() => _out = 'Error: $e'); }
  }

  void _json(bool fmt) {
    try { final d = json.decode(_c1.text); setState(() => _out = fmt ? const JsonEncoder.withIndent('  ').convert(d) : json.encode(d)); }
    catch (e) { setState(() => _out = 'Error: $e'); }
  }

  void _url(bool enc) {
    try { setState(() => _out = enc ? Uri.encodeComponent(_c1.text) : Uri.decodeComponent(_c1.text)); }
    catch (e) { setState(() => _out = 'Error: $e'); }
  }

  void _hash() => setState(() => _out = crypto.sha256.convert(utf8.encode(_c1.text)).toString());

  void _count() {
    final t = _c1.text;
    final w = t.trim().isEmpty ? 0 : t.trim().split(RegExp(r'\s+')).length;
    setState(() => _out = 'Words: $w\nChars: ${t.length}\nLines: ${t.split('\n').length}');
  }

  void _ts() {
    final n = int.tryParse(_c1.text.trim());
    final d = n != null ? DateTime.fromMillisecondsSinceEpoch(n * 1000) : DateTime.tryParse(_c1.text.trim());
    if (d == null) { setState(() => _out = 'Format tidak dikenal'); return; }
    setState(() => _out = 'Unix  : ${d.millisecondsSinceEpoch ~/ 1000}\nUTC   : ${d.toUtc()}\nLokal : $d\nISO   : ${d.toIso8601String()}');
  }

  void _lorem() {
    const p = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.';
    final n = int.tryParse(_c1.text) ?? 3;
    setState(() => _out = List.generate(n, (_) => p).join('\n\n'));
  }

  void _case(String m) {
    final t = _c1.text;
    String r;
    switch (m) {
      case 'u': r = t.toUpperCase(); break;
      case 'l': r = t.toLowerCase(); break;
      case 't': r = t.split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' '); break;
      case 'c': r = t.toLowerCase().replaceAllMapped(RegExp(r'[^a-zA-Z0-9]+(\w)'), (x) => x[1]!.toUpperCase()); break;
      case 's': r = t.toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_]'), ''); break;
      case 'k': r = t.toLowerCase().replaceAll(RegExp(r'\s+'), '-').replaceAll(RegExp(r'[^a-z0-9-]'), ''); break;
      default: r = t;
    }
    setState(() => _out = r);
  }

  Widget _input({String hint = '', int lines = 1}) => TextField(
    controller: _c1, maxLines: lines,
    style: TextStyle(color: NoxTheme.textColor, fontFamily: 'monospace', fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: NoxTheme.muted),
      filled: true, fillColor: NoxTheme.bg3,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: NoxTheme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: NoxTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: NoxTheme.border2)),
      contentPadding: const EdgeInsets.all(12),
    ),
  );

  Widget _btn(String label, VoidCallback fn, {bool p = false}) => GestureDetector(
    onTap: fn,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: p ? Colors.white : NoxTheme.bg3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p ? Colors.white : NoxTheme.border),
      ),
      child: Text(label, style: TextStyle(color: p ? Colors.black : NoxTheme.text2, fontSize: 11)),
    ),
  );

  Widget _outBox() => GestureDetector(
    onTap: _out.isNotEmpty ? _copy : null,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: NoxTheme.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: NoxTheme.border)),
      child: Text(_out.isEmpty ? 'Output...' : _out,
        style: TextStyle(color: _out.isEmpty ? NoxTheme.muted : NoxTheme.textColor, fontFamily: 'monospace', fontSize: 12, height: 1.7)),
    ),
  );

  Widget _check(String l, bool v, Function(bool?) fn) => Row(children: [
    Checkbox(value: v, onChanged: fn, activeColor: Colors.white, checkColor: Colors.black, side: BorderSide(color: NoxTheme.muted)),
    Text(l, style: TextStyle(color: NoxTheme.text2, fontSize: 12)),
    const SizedBox(width: 8),
  ]);

  List<Widget> _content() {
    const g = SizedBox(height: 12);
    switch (widget.id) {
      case 'password': return [
        Row(children: [Text('Length: $_pwLen', style: TextStyle(color: NoxTheme.text2, fontSize: 12))]),
        Slider(value: _pwLen.toDouble(), min: 8, max: 64, divisions: 56, activeColor: Colors.white, inactiveColor: NoxTheme.muted,
          onChanged: (v) => setState(() => _pwLen = v.round())),
        Row(children: [_check('A-Z', _pwU, (v) => setState(() => _pwU = v!)), _check('0-9', _pwN, (v) => setState(() => _pwN = v!)), _check('!@#', _pwS, (v) => setState(() => _pwS = v!))]),
        g, Row(children: [_btn('Generate', _genPW, p: true), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]),
        g, _outBox(),
      ];
      case 'uuid': return [Row(children: [_btn('Generate', _genUUID, p: true), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'base64': return [_input(hint: 'Teks...', lines: 3), g, Row(children: [_btn('Encode', () => _b64(true), p: true), const SizedBox(width: 8), _btn('Decode', () => _b64(false)), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'json': return [_input(hint: '{"key":"val"}', lines: 5), g, Row(children: [_btn('Format', () => _json(true), p: true), const SizedBox(width: 8), _btn('Minify', () => _json(false)), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'url': return [_input(hint: 'URL...', lines: 3), g, Row(children: [_btn('Encode', () => _url(true), p: true), const SizedBox(width: 8), _btn('Decode', () => _url(false)), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'hash': return [_input(hint: 'Teks...'), g, Row(children: [_btn('Generate', _hash, p: true), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'word': return [_input(hint: 'Teks...', lines: 5), g, _btn('Hitung', _count, p: true), g, _outBox()];
      case 'timestamp': return [_input(hint: 'Unix / tanggal...'), g, Row(children: [_btn('Convert', _ts, p: true), const SizedBox(width: 8), _btn('Sekarang', () { _c1.text = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}'; _ts(); }), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'lorem': return [_input(hint: 'Jumlah paragraf...'), g, Row(children: [_btn('Generate', _lorem, p: true), const SizedBox(width: 8), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'case': return [_input(hint: 'Teks...', lines: 3), g, Wrap(spacing: 8, runSpacing: 8, children: [_btn('UPPER', () => _case('u')), _btn('lower', () => _case('l')), _btn('Title', () => _case('t')), _btn('camel', () => _case('c')), _btn('snake', () => _case('s')), _btn('kebab', () => _case('k')), if (_out.isNotEmpty) _btn('Copy', _copy)]), g, _outBox()];
      case 'qr': return [_input(hint: 'Teks atau URL...'), g, _btn('Generate', () => setState(() => _out = _c1.text), p: true), g, if (_out.isNotEmpty) Center(child: Image.network('https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(_out)}&color=e8e8e8&bgcolor=141414', height: 200, width: 200))];
      default: return [Text('Coming soon', style: TextStyle(color: NoxTheme.text2))];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: NoxTheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: NoxTheme.border2),
        ),
        child: Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: NoxTheme.muted, borderRadius: BorderRadius.circular(99))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(_title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace', letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 28, height: 28,
                  decoration: BoxDecoration(color: NoxTheme.bg3, borderRadius: BorderRadius.circular(8), border: Border.all(color: NoxTheme.border)),
                  child: Icon(Icons.close_rounded, color: NoxTheme.text2, size: 16)),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          Divider(color: NoxTheme.border, height: 1),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: _content())),
        ]),
      ),
    );
  }
}
