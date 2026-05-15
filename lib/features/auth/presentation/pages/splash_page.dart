import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../../../core/routes/app_router.dart';

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
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Part du bas (y=1.5) et monte vers le centre (y=0)
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 10));

    final storage = sl<FlutterSecureStorage>();
    String? token;
    try {
      token = await storage.read(key: 'jwt_token');
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // ── Contenu centré ──────────────────────────────────────────────
          Center(
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildLogo(),
              ),
            ),
          ),

          // ── Badge version en bas ────────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(child: _buildVersion()),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _C.greenBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _C.green.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/images/logo-ap.jpg',
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _C.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.greenBorder, width: 1),
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
            'v1.0.0  •  Pharma Pack',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _C.greenText,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}