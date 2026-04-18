import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'tools_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final String name;
  const MainScreen({super.key, required this.name});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.speed_rounded, label: 'Dashboard', index: 0),
    _NavItem(icon: Icons.build_rounded, label: 'Tools', index: 1),
    _NavItem(icon: Icons.tv_rounded, label: 'Jadwal TV', index: 2, comingSoon: false),
    _NavItem(icon: Icons.newspaper_rounded, label: 'Berita', index: 3, comingSoon: false),
    _NavItem(icon: Icons.music_video_rounded, label: 'TikTok DL', index: 4, comingSoon: false),
    _NavItem(icon: Icons.rocket_launch_rounded, label: 'Coming Soon', index: 5),
  ];

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nx_name');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0: return DashboardScreen(name: widget.name);
      case 1: return const ToolsScreen();
      default: return _ComingSoonPlaceholder(index: _currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: NoxTheme.bg,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildPage()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xD9111111),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: NoxTheme.border)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: NoxTheme.bg3,
                    borderRadius: BorderRadius.circular(NoxTheme.radiusSm),
                    border: Border.all(color: NoxTheme.border),
                  ),
                  child: Icon(Icons.menu_rounded, color: NoxTheme.text2, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'NOX', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    TextSpan(text: 'VUS', style: TextStyle(color: NoxTheme.accentDim, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NoxTheme.bg3,
                  borderRadius: BorderRadius.circular(NoxTheme.radiusSm),
                  border: Border.all(color: NoxTheme.border),
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: NoxTheme.text2,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xCC111111),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('MENU', style: TextStyle(
                color: NoxTheme.muted, fontSize: 10,
                letterSpacing: 2, fontFamily: 'monospace',
              )),
            ),
            _drawerItem(Icons.speed_rounded, 'Dashboard', 0),
            _drawerItem(Icons.build_rounded, 'Tools', 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('FITUR', style: TextStyle(
                color: NoxTheme.muted, fontSize: 10,
                letterSpacing: 2, fontFamily: 'monospace',
              )),
            ),
            _drawerItem(Icons.tv_rounded, 'Jadwal TV', 2),
            _drawerItem(Icons.newspaper_rounded, 'Berita', 3),
            _drawerItem(Icons.music_video_rounded, 'TikTok DL', 4),
            _drawerItem(Icons.rocket_launch_rounded, 'Coming Soon', 5),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('ACCOUNT', style: TextStyle(
                color: NoxTheme.muted, fontSize: 10,
                letterSpacing: 2, fontFamily: 'monospace',
              )),
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: NoxTheme.text2, size: 18),
              title: Text('Logout', style: TextStyle(color: NoxTheme.text2, fontSize: 14)),
              onTap: _logout,
              dense: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.white : NoxTheme.text2, size: 18),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : NoxTheme.text2,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
      dense: true,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  final bool comingSoon;
  _NavItem({required this.icon, required this.label, required this.index, this.comingSoon = false});
}

class _ComingSoonPlaceholder extends StatelessWidget {
  final int index;
  const _ComingSoonPlaceholder({required this.index});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rocket_launch_rounded, color: NoxTheme.muted, size: 48),
          const SizedBox(height: 16),
          Text('Coming Soon', style: TextStyle(
            color: NoxTheme.text2, fontSize: 18, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          Text('Fitur ini lagi dikembangkan', style: TextStyle(
            color: NoxTheme.muted, fontSize: 13, fontFamily: 'monospace',
          )),
        ],
      ),
    );
  }
}
