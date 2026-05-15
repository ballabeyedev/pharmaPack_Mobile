import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../../injection_container.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/app_version_service.dart';

class _C {
  static const green       = Color(0xFF06C167);
  static const greenLight  = Color(0xFFE8F5EC);
  static const greenBorder = Color(0xFFB8DEC4);
  static const greenText   = Color(0xFF27834E);
  static const black       = Color(0xFF1A2E1F);
  static const bg          = Color(0xFFF0F4F1);
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;

  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  String _version = '';

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initVersion();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    );

    // Fade
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5)),
    );

    // Scale (effet premium)
    _scale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    // Slide doux
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(curve);

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 1200), _checkAuth);
  }

  // ── VERSION SERVICE ─────────────────────────────
  Future<void> _initVersion() async {
    final v = await AppVersion.getVersion();
    if (!mounted) return;

    setState(() => _version = v);
  }

  // ── AUTH FLOW CLEAN ─────────────────────────────
  Future<void> _checkAuth() async {
    try {
      final storage = sl<FlutterSecureStorage>();
      final token = await storage.read(key: 'jwt_token');

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        _goLogin();
        return;
      }

      if (Jwt.isExpired(token)) {
        await storage.delete(key: 'jwt_token');
        _goLogin();
        return;
      }

      _goHome();
    } catch (_) {
      _goLogin();
    }
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.loginRoute,
          (_) => false,
    );
  }

  void _goLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.loginRoute,
          (_) => false,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── UI ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [

          // ── LOGO CENTER ─────────────────────
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ScaleTransition(
                  scale: _scale,
                  child: _logo(),
                ),
              ),
            ),
          ),

          // ── VERSION ─────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _version.isEmpty ? 0 : 1,
              child: Center(child: _versionWidget()),
            ),
          ),
        ],
      ),
    );
  }

  // ── LOGO PRO ─────────────────────────
  Widget _logo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _C.greenBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _C.green.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          'assets/img/logo.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── VERSION UI PRO ─────────────────────
  Widget _versionWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: _C.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.greenBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _C.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _version.isEmpty ? 'Loading...' : _version,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _C.greenText,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '• Pharma Pack',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _C.greenText.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}