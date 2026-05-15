import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/toastNotif.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/PasswordTextField.dart';

// ─── Palette Vert Clair Professionnel ─────────────────────────────────────────
class _C {
  static const green        = Color(0xFF4CAF50);   // vert clair principal
  static const greenMid     = Color(0xFF66BB6A);   // vert moyen doux
  static const greenDeep    = Color(0xFF388E3C);   // vert profond pour textes
  static const greenLight   = Color(0xFFF1F8F1);   // fond vert très pâle
  static const greenSoft    = Color(0xFFE8F5E9);   // vert pastel
  static const greenBorder  = Color(0xFFC8E6C9);   // bordure verte douce
  static const greenText    = Color(0xFF2E7D32);   // texte vert foncé
  static const accent       = Color(0xFF26A69A);   // teal médical doux
  static const accentLight  = Color(0xFFE0F2F1);
  static const black        = Color(0xFF212121);   // noir doux
  static const white        = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF9FBF9);   // fond page blanc-vert
  static const surface      = Color(0xFFF4FAF4);   // surface champs
  static const border       = Color(0xFFE0EDE0);
  static const label        = Color(0xFF37474F);
  static const placeholder  = Color(0xFFB0BEC5);
  static const sub          = Color(0xFF78909C);
  static const divider      = Color(0xFFE8F5E9);
  static const cardShadow   = Color(0x0A4CAF50);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _identifiantController = TextEditingController();
  final _passwordController    = TextEditingController();
  final _formKey               = GlobalKey<FormState>();

  final _identifiantFocus = FocusNode();
  final _passwordFocus    = FocusNode();

  late AnimationController _masterCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _floatCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _masterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _masterCtrl, curve: Curves.easeOutCubic));

    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    _floatAnim = Tween<double>(begin: -5.0, end: 5.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _masterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardCtrl.forward();
    });

    _identifiantFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    _identifiantFocus.dispose();
    _passwordFocus.dispose();
    _masterCtrl.dispose();
    _cardCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      final input   = _identifiantController.text.trim();
      final isEmail = RegExp(r'\S+@\S+\.\S+').hasMatch(input);
      context.read<AuthBloc>().add(
        LoginRequested(
          email:        isEmail ? input : null,
          telephone:    isEmail ? null  : input,
          mot_de_passe: _passwordController.text,
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            final role = user.role.toLowerCase();
            if (role == 'pharmacie') {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.pharmacieRoute, (_) => false, arguments: user);
              showToast(context, 'Connexion réussie',
                  'Bienvenue sur PharmaPack', ToastificationType.success);
            }else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.loginRoute, (_) => false);
              showToast(context, 'Erreur',
                  'Rôle non reconnu.', ToastificationType.error);
            }
          } else if (state is AuthFailure) {
            showToast(
              context,
              'Échec de la connexion',
              state.message,
              ToastificationType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            _buildTopBar(),
                            const SizedBox(height: 40),
                            _buildIllustration(),
                            const SizedBox(height: 36),
                            _buildHeader(),
                            const SizedBox(height: 28),
                            FadeTransition(
                              opacity: _cardFade,
                              child: SlideTransition(
                                position: _cardSlide,
                                child: _buildCard(isLoading),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════

  // ── Fond décoratif sobre ──────────────────────────────────────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -60, left: -50,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                _C.green.withOpacity(0.07),
                _C.green.withOpacity(0.0),
              ]),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -80, right: -60,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                _C.greenMid.withOpacity(0.08),
                _C.greenMid.withOpacity(0.0),
              ]),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 55, right: 16,
          child: Opacity(
            opacity: 0.07,
            child: SizedBox(
              width: 72, height: 72,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 7,
                  mainAxisSpacing: 7,
                ),
                itemCount: 16,
                itemBuilder: (_, __) => Container(
                  decoration: const BoxDecoration(
                    color: _C.green, shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Barre du haut ──────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo + Nom
        Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _C.green,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _C.green.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_pharmacy_outlined,
                color: _C.white, size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Pharma',
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Pack',
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.green,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ]),
                ),
                Text(
                  'Santé & Bien-être',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: _C.sub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Badge sécurisé
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: _C.greenSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.greenBorder, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 13, color: _C.green),
              const SizedBox(width: 5),
              Text(
                'Sécurisé',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _C.greenText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Illustration centrale flottante ───────────────────────────────────────
  Widget _buildIllustration() {
    return Center(
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        ),
        child: SizedBox(
          width: 180, height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo extérieur
              Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.greenSoft.withOpacity(0.7),
                ),
              ),
              // Anneau intermédiaire
              Container(
                width: 116, height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.greenSoft,
                  border: Border.all(color: _C.greenBorder, width: 1.5),
                ),
              ),
              // Disque central
              Container(
                width: 82, height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.green,
                  boxShadow: [
                    BoxShadow(
                      color: _C.green.withOpacity(0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: _C.white, size: 36,
                ),
              ),
              // Pastille haut droite
              Positioned(
                top: 6, right: 6,
                child: _buildSatellite(
                  Icons.medication_outlined,
                  _C.accent,
                  _C.accentLight,
                ),
              ),
              // Pastille bas gauche
              Positioned(
                bottom: 6, left: 6,
                child: _buildSatellite(
                  Icons.store_outlined,
                  _C.green,
                  _C.greenSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSatellite(IconData icon, Color color, Color bg) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  // ── En-tête sobre ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connexion',
          style: GoogleFonts.sora(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _C.black,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 28, height: 3,
              decoration: BoxDecoration(
                color: _C.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Accédez à votre espace personnel',
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                color: _C.sub,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Carte principale ───────────────────────────────────────────────────────
  Widget _buildCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _C.cardShadow,
            blurRadius: 36,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre carte avec accent ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 5, height: 20,
                decoration: BoxDecoration(
                  color: _C.green,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Identifiez-vous',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Identifiant ──────────────────────────────────────────────────
          _buildFieldLabel('E-mail ou téléphone'),
          const SizedBox(height: 8),
          _buildIdentifiantField(),
          const SizedBox(height: 18),

          // ── Mot de passe ─────────────────────────────────────────────────
          _buildFieldLabel('Mot de passe'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 12),

          // ── Mot de passe oublié ──────────────────────────────────────────
          _buildForgotLink(),
          const SizedBox(height: 26),

          // ── Bouton connexion ─────────────────────────────────────────────
          _buildLoginButton(isLoading),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 18),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  // ── Label champ ────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _C.sub,
        letterSpacing: 1.0,
      ),
    );
  }

  // ── Champ identifiant ──────────────────────────────────────────────────────
  Widget _buildIdentifiantField() {
    final focused = _identifiantFocus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 52,
      decoration: BoxDecoration(
        color: focused ? _C.white : _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? _C.green : _C.border,
          width: focused ? 1.8 : 1.4,
        ),
        boxShadow: focused
            ? [
          BoxShadow(
            color: _C.green.withOpacity(0.09),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.alternate_email_rounded,
            size: 18,
            color: focused ? _C.green : _C.placeholder,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.transparent,
                  error: Colors.transparent,
                ),
              ),
              child: TextFormField(
                controller: _identifiantController,
                focusNode: _identifiantFocus,
                keyboardType: TextInputType.emailAddress,
                cursorColor: _C.green,
                style: GoogleFonts.dmSans(
                  color: _C.black, fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'exemple@mail.com ou +221 77...',
                  hintStyle: GoogleFonts.dmSans(
                    color: _C.placeholder, fontSize: 13.5,
                  ),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero),
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero),
                  focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.zero),
                  filled: false,
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.only(right: 14, top: 14, bottom: 14),
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Ce champ est requis' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Champ mot de passe ─────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    final focused = _passwordFocus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 52,
      decoration: BoxDecoration(
        color: focused ? _C.white : _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? _C.green : _C.border,
          width: focused ? 1.8 : 1.4,
        ),
        boxShadow: focused
            ? [
          BoxShadow(
            color: _C.green.withOpacity(0.09),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: focused ? _C.green : _C.placeholder,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PasswordTextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              hintText: 'Votre mot de passe',
              height: 52,
              width: double.infinity,
              borderRadius: BorderRadius.circular(0),
              style: GoogleFonts.dmSans(
                color: _C.black, fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Ce champ est requis' : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mot de passe oublié ────────────────────────────────────────────────────
  Widget _buildForgotLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/forgot-password'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_reset_rounded,
                size: 13, color: _C.green),
            const SizedBox(width: 5),
            Text(
              'Mot de passe oublié ?',
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _C.greenText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bouton connexion ───────────────────────────────────────────────────────
  Widget _buildLoginButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: isLoading ? _C.green.withOpacity(0.55) : _C.green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLoading
            ? null
            : [
          BoxShadow(
            color: _C.green.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _onLoginPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: _C.white.withOpacity(0.15),
          highlightColor: _C.white.withOpacity(0.06),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(_C.white),
                  ),
                )
              else ...[
                const Icon(Icons.login_rounded,
                    color: _C.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Se connecter',
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Séparateur ─────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _C.divider, _C.divider.withOpacity(0),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'ou',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.placeholder,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _C.divider.withOpacity(0), _C.divider,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ── Lien inscription ───────────────────────────────────────────────────────
  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: 'Pas encore de compte ? ',
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: _C.sub,
            ),
          ),
          TextSpan(
            text: 'Créer un compte',
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _C.green,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.of(context).pushNamed('/register'),
          ),
        ]),
      ),
    );
  }
}