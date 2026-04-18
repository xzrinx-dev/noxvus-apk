import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import '../theme.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const _tools = [
    {'id': 'qr', 'label': 'QR Code', 'icon': Icons.qr_code_rounded},
    {'id': 'password', 'label': 'Password', 'icon': Icons.key_rounded},
    {'id': 'base64', 'label': 'Base64', 'icon': Icons.swap_horiz_rounded},
    {'id': 'json', 'label': 'JSON', 'icon': Icons.code_rounded},
    {'id': 'uuid', 'label': 'UUID', 'icon': Icons.fingerprint_rounded},
    {'id': 'word', 'label': 'Counter', 'icon': Icons.text_fields_rounded},
    {'id': 'url', 'label': 'URL Encode', 'icon': Icons.link_rounded},
    {'id': 'hash', 'label': 'Hash', 'icon': Icons.lock_rounded},
    {'id': 'timestamp', 'label': 'Timestamp', 'icon': Icons.timer_rounded},
    {'id': 'lorem', 'label': 'Lorem', 'icon': Icons.article_rounded},
    {'id': 'case', 'label': 'Case', 'icon': Icons.text_format_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tools Collection', style: TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('${_tools.length} tools tersedia', style: TextStyle(
          color: NoxTheme.text2, fontSize: 11, fontFamily: 'monospace')),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1,
            crossAxisSpacing: 10, mainAxisSpacing: 10,
          ),
          itemCount: _tools.length,
          itemBuilder: (ctx, i) {
            final t = _tools[i];
            return _ToolCard(
              icon: t['icon'] as IconData,
              label: t['label'] as String,
              onTap: () => showModalBottomSheet(
                context: ctx,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _ToolModal(id: t['id'] as String),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ToolCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NoxTheme.card,
          borderRadius: BorderRadius.circular(NoxTheme.radius),
          border: Border.all(color: NoxTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: NoxTheme.accentDim, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              color: NoxTheme.text2, fontSize: 10,
              fontFamily: 'monospace', letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _ToolModal extends StatefulWidget {
  final String id;
  const _ToolModal({required this.id});
  @override
  State<_ToolModal> createState() => _ToolModalState();
}

class _ToolModalState extends State<_ToolModal> {
  final _ctrl1 = TextEditingController();
  String _output = '';
  int _pwLen = 16;
  bool _pwUpper = true, _pwNum = true, _pwSym = true;

  String get _title => {
    'qr': 'QR Generator', 'password': 'Password Generator',
    'base64': 'Base64 Encode/Decode', 'json': 'JSON Formatter',
    'uuid': 'UUID Generator', 'word': 'Word Counter',
    'url': 'URL Encode/Decode', 'hash': 'Hash SHA-256',
    'timestamp': 'Timestamp', 'lorem': 'Lorem Ipsum',
    'case': 'Case Converter',
  }[widget.id] ?? 'Tool';

  void _copy() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied!'),
      duration: Duration(seconds: 1),
    ));
  }

  void _genPW() {
    String chars = 'abcdefghijklmnopqrstuvwxyz';
    if (_pwUpper) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_pwNum) chars += '0123456789';
    if (_pwSym) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final rand = Random.secure();
    setState(() => _output = List.generate(_pwLen, (_) => chars[rand.nextInt(chars.length)]).join());
  }

  void _genUUID() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    setState(() => _output =
      '${hex.substring(0,8)}-${hex.substring(8,12)}-${hex.substring(12,16)}-${hex.substring(16,20)}-${hex.substring(20)}');
  }

  void _doBase64(bool encode) {
    try {
      setState(() => _output = encode
        ? base64Encode(utf8.encode(_ctrl1.text))
        : utf8.decode(base64Decode(_ctrl1.text)));
    } catch (e) { setState(() => _output = 'Error: $e'); }
  }

  void _doJSON(bool format) {
    try {
      final d = json.decode(_ctrl1.text);
      setState(() => _output = format
        ? const JsonEncoder.withIndent('  ').convert(d)
        : json.encode(d));
    } catch (e) { setState(() => _output = 'Error: $e'); }
  }

  void _doURL(bool encode) {
    setState(() => _output = encode
      ? Uri.encodeComponent(_ctrl1.text)
      : Uri.decodeComponent(_ctrl1.text));
  }

  void _doHash() {
    final hash = crypto.sha256.convert(utf8.encode(_ctrl1.text));
    setState(() => _output = hash.toString());
  }

  void _countWords() {
    final t = _ctrl1.text;
    final words = t.trim().isEmpty ? 0 : t.trim().split(RegExp(r'\s+')).length;
    setState(() => _output = 'Words: $words\nChars: ${t.length}\nLines: ${t.split('\n').length}');
  }

  void _doTimestamp() {
    final input = _ctrl1.text.trim();
    DateTime? d;
    final n = int.tryParse(input);
    if (n != null) d = DateTime.fromMillisecondsSinceEpoch(n * 1000);
    else d = DateTime.tryParse(input);
    if (d == null) { setState(() => _output = 'Format tidak dikenal'); return; }
    setState(() => _output =
      'Unix  : ${d!.millisecondsSinceEpoch ~/ 1000}\nUTC   : ${d.toUtc()}\nLokal : $d\nISO   : ${d.toIso8601String()}');
  }

  void _doLorem() {
    const p = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.';
    final n = int.tryParse(_ctrl1.text) ?? 3;
    setState(() => _output = List.generate(n, (_) => p).join('\n\n'));
  }

  void _doCase(String mode) {
    final t = _ctrl1.text;
    String r;
    switch (mode) {
      case 'u': r = t.toUpperCase(); break;
      case 'l': r = t.toLowerCase(); break;
      case 't': r = t.split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' '); break;
      case 'c': r = t.toLowerCase().replaceAllMapped(RegExp(r'[^a-zA-Z0-9]+(\w)'), (m) => m[1]!.toUpperCase()); break;
      case 's': r = t.toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_]'), ''); break;
      case 'k': r = t.toLowerCase().replaceAll(RegExp(r'\s+'), '-').replaceAll(RegExp(r'[^a-z0-9-]'), ''); break;
      default: r = t;
    }
    setState(() => _output = r);
  }

  Widget _input({String hint = '', int maxLines = 1}) => TextField(
    controller: _ctrl1, maxLines: maxLines,
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

  Widget _btn(String label, VoidCallback onTap, {bool primary = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: primary ? Colors.white : NoxTheme.bg3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primary ? Colors.white : NoxTheme.border),
      ),
      child: Text(label, style: TextStyle(
        color: primary ? Colors.black : NoxTheme.text2,
        fontSize: 11, fontFamily: 'monospace',
      )),
    ),
  );

  Widget _outputBox() => GestureDetector(
    onTap: _output.isNotEmpty ? _copy : null,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NoxTheme.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NoxTheme.border),
      ),
      child: Text(
        _output.isEmpty ? 'Output...' : _output,
        style: TextStyle(
          color: _output.isEmpty ? NoxTheme.muted : NoxTheme.textColor,
          fontFamily: 'monospace', fontSize: 12, height: 1.7,
        ),
      ),
    ),
  );

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
        child: Column(
          children: [
            Container(width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: NoxTheme.muted, borderRadius: BorderRadius.circular(99))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(_title.toUpperCase(), style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontFamily: 'monospace',
                    letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: NoxTheme.bg3, borderRadius: BorderRadius.circular(8), border: Border.all(color: NoxTheme.border)),
                      child: Icon(Icons.close_rounded, color: NoxTheme.text2, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: NoxTheme.border, height: 1),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    final gap = const SizedBox(height: 12);
    switch (widget.id) {
      case 'password': return [
        Row(children: [Text('Length: $_pwLen', style: TextStyle(color: NoxTheme.text2, fontSize: 12, fontFamily: 'monospace'))]),
        Slider(value: _pwLen.toDouble(), min: 8, max: 64, divisions: 56,
          activeColor: Colors.white, inactiveColor: NoxTheme.muted,
          onChanged: (v) => setState(() => _pwLen = v.round())),
        Row(children: [
          _checkBox('A-Z', _pwUpper, (v) => setState(() => _pwUpper = v!)),
          _checkBox('0-9', _pwNum, (v) => setState(() => _pwNum = v!)),
          _checkBox('!@#', _pwSym, (v) => setState(() => _pwSym = v!)),
        ]),
        gap,
        Row(children: [_btn('Generate', _genPW, primary: true), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'uuid': return [
        Row(children: [_btn('Generate', _genUUID, primary: true), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'word': return [
        _input(hint: 'Ketik atau paste teks...', maxLines: 5), gap,
        _btn('Hitung', _countWords, primary: true), gap, _outputBox(),
      ];
      case 'base64': return [
        _input(hint: 'Input teks...', maxLines: 3), gap,
        Row(children: [_btn('Encode', () => _doBase64(true), primary: true), const SizedBox(width: 8), _btn('Decode', () => _doBase64(false)), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'json': return [
        _input(hint: '{"key":"value"}', maxLines: 5), gap,
        Row(children: [_btn('Format', () => _doJSON(true), primary: true), const SizedBox(width: 8), _btn('Minify', () => _doJSON(false)), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'url': return [
        _input(hint: 'URL atau teks...', maxLines: 3), gap,
        Row(children: [_btn('Encode', () => _doURL(true), primary: true), const SizedBox(width: 8), _btn('Decode', () => _doURL(false)), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'hash': return [
        _input(hint: 'Teks untuk di-hash...'), gap,
        Row(children: [_btn('Generate SHA-256', _doHash, primary: true), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'timestamp': return [
        _input(hint: 'Unix timestamp atau tanggal...'), gap,
        Row(children: [
          _btn('Convert', _doTimestamp, primary: true), const SizedBox(width: 8),
          _btn('Sekarang', () { _ctrl1.text = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(); _doTimestamp(); }),
          const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy),
        ]),
        gap, _outputBox(),
      ];
      case 'lorem': return [
        _input(hint: 'Jumlah paragraf (default 3)'), gap,
        Row(children: [_btn('Generate', _doLorem, primary: true), const SizedBox(width: 8), if (_output.isNotEmpty) _btn('Copy', _copy)]),
        gap, _outputBox(),
      ];
      case 'case': return [
        _input(hint: 'Teks input...', maxLines: 3), gap,
        Wrap(spacing: 8, runSpacing: 8, children: [
          _btn('UPPER', () => _doCase('u')), _btn('lower', () => _doCase('l')),
          _btn('Title', () => _doCase('t')), _btn('camel', () => _doCase('c')),
          _btn('snake', () => _doCase('s')), _btn('kebab', () => _doCase('k')),
          if (_output.isNotEmpty) _btn('Copy', _copy),
        ]),
        gap, _outputBox(),
      ];
      case 'qr': return [
        _input(hint: 'Teks atau URL...'), gap,
        _btn('Generate', () => setState(() => _output = _ctrl1.text), primary: true),
        gap,
        if (_output.isNotEmpty) Center(
          child: Image.network(
            'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(_output)}&color=e8e8e8&bgcolor=141414&margin=10',
            height: 200, width: 200,
          ),
        ),
      ];
      default: return [Text('Coming soon', style: TextStyle(color: NoxTheme.text2))];
    }
  }

  Widget _checkBox(String label, bool val, Function(bool?) onChanged) {
    return Row(children: [
      Checkbox(value: val, onChanged: onChanged, activeColor: Colors.white, checkColor: Colors.black, side: BorderSide(color: NoxTheme.muted)),
      Text(label, style: TextStyle(color: NoxTheme.text2, fontSize: 12)),
      const SizedBox(width: 8),
    ]);
  }
}
