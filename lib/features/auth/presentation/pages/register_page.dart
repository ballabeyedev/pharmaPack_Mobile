import 'dart:io';

import 'package:pharmapack/core/routes/app_router.dart';
import 'package:pharmapack/features/auth/presentation/widgets/PasswordTextField.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/widgets/toastNotif.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ─── Palette vert clair professionnel ────────────────────────────────────────
class _C {
  static const green        = Color(0xFF4CAF50);
  static const greenMid     = Color(0xFF66BB6A);
  static const greenDeep    = Color(0xFF388E3C);
  static const greenLight   = Color(0xFFF1F8F1);
  static const greenSoft    = Color(0xFFE8F5E9);
  static const greenBorder  = Color(0xFFC8E6C9);
  static const greenText    = Color(0xFF2E7D32);
  static const accent       = Color(0xFF26A69A);
  static const accentLight  = Color(0xFFE0F2F1);
  static const black        = Color(0xFF212121);
  static const white        = Color(0xFFFFFFFF);
  static const bg           = Color(0xFFF9FBF9);
  static const surface      = Color(0xFFF4FAF4);
  static const border       = Color(0xFFE0EDE0);
  static const label        = Color(0xFF37474F);
  static const placeholder  = Color(0xFFB0BEC5);
  static const sub          = Color(0xFF78909C);
  static const divider      = Color(0xFFE8F5E9);
  static const error        = Color(0xFFE53935);
  static const orange       = Color(0xFFFF9800);
  static const cardShadow   = Color(0x0A4CAF50);
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {

  // ── Contrôleurs champs personnels ─────────────────────────────────────────
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();
  final _addressController   = TextEditingController();
  final _passwordController  = TextEditingController();

  // ── Contrôleurs champs pharmacie ─────────────────────────────────────────
  final _pharmaNameController    = TextEditingController();
  final _pharmaEmailController   = TextEditingController();
  final _pharmaPhoneController   = TextEditingController();
  final _pharmaCityController    = TextEditingController();
  final _pharmaAddressController = TextEditingController();

  // ── Focus nodes personnels ────────────────────────────────────────────────
  final _firstNameFocus  = FocusNode();
  final _lastNameFocus   = FocusNode();
  final _emailFocus      = FocusNode();
  final _addressFocus    = FocusNode();
  final _passwordFocus   = FocusNode();

  // ── Focus nodes pharmacie ─────────────────────────────────────────────────
  final _pharmaNameFocus    = FocusNode();
  final _pharmaEmailFocus   = FocusNode();
  final _pharmaPhoneFocus   = FocusNode();
  final _pharmaCityFocus    = FocusNode();
  final _pharmaAddressFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  String? _completePhoneNumber;
  String? _pharmaCompletePhone;
  File?   _profileImage;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _masterCtrl;
  late AnimationController _cardCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _cardFade;
  late Animation<Offset>   _cardSlide;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    _fadeAnim  = CurvedAnimation(parent: _masterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _masterCtrl, curve: Curves.easeOutCubic));

    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    _masterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _cardCtrl.forward();
    });

    for (final n in [
      _firstNameFocus, _lastNameFocus, _emailFocus, _addressFocus,
      _passwordFocus, _pharmaNameFocus, _pharmaEmailFocus,
      _pharmaPhoneFocus, _pharmaCityFocus, _pharmaAddressFocus,
    ]) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameController, _lastNameController, _emailController,
      _phoneController, _addressController, _passwordController,
      _pharmaNameController, _pharmaEmailController, _pharmaPhoneController,
      _pharmaCityController, _pharmaAddressController,
    ]) { c.dispose(); }

    for (final n in [
      _firstNameFocus, _lastNameFocus, _emailFocus, _addressFocus,
      _passwordFocus, _pharmaNameFocus, _pharmaEmailFocus,
      _pharmaPhoneFocus, _pharmaCityFocus, _pharmaAddressFocus,
    ]) { n.dispose(); }

    _masterCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          nom:                _lastNameController.text.trim(),
          prenom:             _firstNameController.text.trim(),
          email:              _emailController.text.trim(),
          mot_de_passe:       _passwordController.text,
          adresse:            _addressController.text.trim(),
          telephone:          _completePhoneNumber ?? _phoneController.text.trim(),
          nomPharmacie:       _pharmaNameController.text.trim(),
          emailPharmacie:     _pharmaEmailController.text.trim(),
          telephonePharmacie: _pharmaCompletePhone ?? _pharmaPhoneController.text.trim(),
          villePharmacie:     _pharmaCityController.text.trim(),
          adressePharmacie:   _pharmaAddressController.text.trim(),
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
        listenWhen: (prev, curr) => prev != curr,
        listener: (context, state) {
          if (state is AuthSuccess) {
            FocusScope.of(context).unfocus();
            showToast(context, 'Inscription réussie',
                'Bienvenue sur PharmaPack !',
                ToastificationType.success);
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.loginRoute, (_) => false,
            );
            context.read<AuthBloc>().add(ResetAuthState());
          } else if (state is AuthFailure) {
            showToast(context, "Échec de l'inscription", state.message,
                ToastificationType.error);
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
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildTopBar(),
                          const SizedBox(height: 28),
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildProfilePicker(),
                          const SizedBox(height: 28),
                          FadeTransition(
                            opacity: _cardFade,
                            child: SlideTransition(
                              position: _cardSlide,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Section compte personnel ──────────
                                    _buildSectionBanner(
                                      icon: Icons.person_outline_rounded,
                                      title: 'Informations personnelles',
                                      subtitle: 'Responsable ou gérant de la pharmacie',
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildField(
                                            label: 'Prénom',
                                            hint: 'Jane',
                                            controller: _firstNameController,
                                            focusNode: _firstNameFocus,
                                            icon: Icons.person_outline_rounded,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildField(
                                            label: 'Nom',
                                            hint: 'Doe',
                                            controller: _lastNameController,
                                            focusNode: _lastNameFocus,
                                            icon: Icons.badge_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPhoneField(
                                      controller: _phoneController,
                                      label: 'Téléphone',
                                      onChanged: (p) => setState(
                                              () => _completePhoneNumber = p.completeNumber),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'Adresse e-mail',
                                      hint: 'exemple@gmail.com',
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Champ requis';
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                          return 'E-mail invalide';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPasswordField(),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'Adresse',
                                      hint: 'Dakar, Sénégal',
                                      controller: _addressController,
                                      focusNode: _addressFocus,
                                      icon: Icons.location_on_outlined,
                                    ),
                                    const SizedBox(height: 28),

                                    // ── Section pharmacie ─────────────────
                                    _buildSectionBanner(
                                      icon: Icons.local_pharmacy_outlined,
                                      title: 'Votre pharmacie',
                                      subtitle: 'Informations officielles de l\'établissement',
                                      isPharmacy: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'Nom de la pharmacie',
                                      hint: 'Pharmacie Centrale',
                                      controller: _pharmaNameController,
                                      focusNode: _pharmaNameFocus,
                                      icon: Icons.storefront_outlined,
                                      isSecondary: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'E-mail de la pharmacie',
                                      hint: 'pharmacie@exemple.com',
                                      controller: _pharmaEmailController,
                                      focusNode: _pharmaEmailFocus,
                                      icon: Icons.mark_email_unread_outlined,
                                      isSecondary: true,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Champ requis';
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                          return 'E-mail invalide';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPhoneField(
                                      controller: _pharmaPhoneController,
                                      label: 'Téléphone de la pharmacie',
                                      isSecondary: true,
                                      onChanged: (p) => setState(
                                              () => _pharmaCompletePhone = p.completeNumber),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildField(
                                            label: 'Ville',
                                            hint: 'Dakar',
                                            controller: _pharmaCityController,
                                            focusNode: _pharmaCityFocus,
                                            icon: Icons.location_city_outlined,
                                            isSecondary: true,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildField(
                                            label: 'Adresse',
                                            hint: 'Rue 10, Plateau',
                                            controller: _pharmaAddressController,
                                            focusNode: _pharmaAddressFocus,
                                            icon: Icons.place_outlined,
                                            isSecondary: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSubmitButton(isLoading),
                          const SizedBox(height: 20),
                          _buildLoginLink(),
                          const SizedBox(height: 40),
                        ],
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
                  crossAxisCount: 4, crossAxisSpacing: 7, mainAxisSpacing: 7,
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
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _C.greenBorder, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: _C.green.withOpacity(0.06),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: _C.green),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _C.green,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _C.green.withOpacity(0.28),
                blurRadius: 12, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.local_pharmacy_outlined,
              color: _C.white, size: 22),
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
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: _C.black, letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Pack',
                  style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: _C.green, letterSpacing: -0.5,
                  ),
                ),
              ]),
            ),
            Text(
              'Distribution pharmaceutique',
              style: GoogleFonts.dmSans(
                fontSize: 10, color: _C.sub, fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── En-tête épuré ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créer un compte',
          style: GoogleFonts.sora(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _C.black,
            letterSpacing: -0.9,
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
            const SizedBox(width: 10),
            Text(
              "Accédez à notre catalogue d'emballage",
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _C.sub,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Photo de profil ────────────────────────────────────────────────────────
  Widget _buildProfilePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                Container(
                  width: 92, height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _profileImage == null ? _C.greenSoft : null,
                    border: Border.all(
                      color: _profileImage != null ? _C.green : _C.greenBorder,
                      width: _profileImage != null ? 2.5 : 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _C.green.withOpacity(0.12),
                        blurRadius: 16, offset: const Offset(0, 4),
                      ),
                    ],
                    image: _profileImage != null
                        ? DecorationImage(
                      image: FileImage(_profileImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _profileImage == null
                      ? Icon(Icons.person_outline_rounded,
                      size: 34, color: _C.green.withOpacity(0.55))
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: _C.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _C.green.withOpacity(0.35),
                          blurRadius: 6, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: _C.white, size: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _profileImage != null ? 'Photo sélectionnée' : 'Ajouter une photo',
            style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: _profileImage != null ? _C.green : _C.sub,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bannière de section ────────────────────────────────────────────────────
  Widget _buildSectionBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPharmacy = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isPharmacy ? _C.greenSoft : _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPharmacy ? _C.greenBorder : _C.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.cardShadow,
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isPharmacy ? _C.green : _C.greenSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19,
                color: isPharmacy ? _C.white : _C.green),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isPharmacy ? _C.greenText : _C.label,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 11, color: _C.sub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Label ──────────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String text,
      {bool required = false, bool isSecondary = false}) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSecondary ? _C.greenText : _C.sub,
            letterSpacing: 1.0,
          ),
        ),
        if (required)
          Text(' *',
              style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: FontWeight.w700, color: _C.error,
              )),
      ],
    );
  }

  // ── Champ texte générique ──────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    bool isSecondary = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final focused    = focusNode.hasFocus;
    final activeColor = isSecondary ? _C.green : _C.greenDeep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, required: true, isSecondary: isSecondary),
        const SizedBox(height: 7),
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.transparent,
              error: Colors.transparent,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: focused ? _C.white : _C.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: focused ? activeColor : _C.border,
                width: focused ? 1.8 : 1.4,
              ),
              boxShadow: focused
                  ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.09),
                  blurRadius: 10, offset: const Offset(0, 3),
                ),
              ]
                  : [],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  icon, size: 17,
                  color: focused ? activeColor : _C.placeholder,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    cursorColor: activeColor,
                    style: GoogleFonts.dmSans(
                      color: _C.black, fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
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
                      contentPadding: const EdgeInsets.only(
                          right: 14, top: 14, bottom: 14),
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                    ),
                    validator: validator ??
                            (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Champ téléphone ────────────────────────────────────────────────────────
  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    bool isSecondary = false,
    required Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, required: true, isSecondary: isSecondary),
        const SizedBox(height: 7),
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _C.green, error: Colors.transparent,
            ),
          ),
          child: IntlPhoneField(
            controller: controller,
            initialCountryCode: 'SN',
            cursorColor: _C.green,
            style: GoogleFonts.dmSans(
              color: _C.black, fontSize: 14, fontWeight: FontWeight.w500,
            ),
            dropdownTextStyle: GoogleFonts.dmSans(
              color: _C.black, fontSize: 14, fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '77 123 45 67',
              hintStyle: GoogleFonts.dmSans(
                  color: _C.placeholder, fontSize: 13.5),
              filled: true,
              fillColor: _C.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _C.border, width: 1.4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _C.border, width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.green, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _C.error, width: 1.4),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _C.error, width: 1.4),
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            onChanged: onChanged,
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) return 'Numéro requis';
              if (phone.number.length < 7) return 'Numéro invalide';
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ── Champ mot de passe ─────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    final focused = _passwordFocus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Mot de passe', required: true),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: focused ? _C.white : _C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focused ? _C.greenDeep : _C.border,
              width: focused ? 1.8 : 1.4,
            ),
            boxShadow: focused
                ? [
              BoxShadow(
                color: _C.green.withOpacity(0.09),
                blurRadius: 10, offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.lock_outline_rounded, size: 17,
                  color: focused ? _C.greenDeep : _C.placeholder),
              const SizedBox(width: 10),
              Expanded(
                child: PasswordTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hintText: 'Créez un mot de passe sécurisé',
                  height: 52,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(0),
                  style: GoogleFonts.dmSans(
                    color: _C.black, fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (v.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildPasswordStrength(),
      ],
    );
  }

  Widget _buildPasswordStrength() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _passwordController,
      builder: (_, value, __) {
        final len = value.text.length;
        if (len == 0) return const SizedBox.shrink();
        final strength = len < 6 ? 0 : len < 10 ? 1 : 2;
        final colors   = [_C.error, _C.orange, _C.green];
        final labels   = ['Faible', 'Moyen', 'Fort'];
        return Row(
          children: [
            ...List.generate(3, (i) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                decoration: BoxDecoration(
                  color: i <= strength ? colors[strength] : _C.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors[strength].withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[strength],
                style: GoogleFonts.dmSans(
                  fontSize: 10.5, fontWeight: FontWeight.w700,
                  color: colors[strength],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Bouton S'inscrire ──────────────────────────────────────────────────────
  Widget _buildSubmitButton(bool isLoading) {
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
            blurRadius: 18, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _submitRegistration,
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
                const Icon(Icons.how_to_reg_outlined,
                    color: _C.white, size: 19),
                const SizedBox(width: 10),
                Text(
                  'Créer mon compte',
                  style: GoogleFonts.sora(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: _C.white, letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Lien connexion ─────────────────────────────────────────────────────────
  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: 'Déjà un compte ? ',
            style: GoogleFonts.dmSans(
              fontSize: 13.5, fontWeight: FontWeight.w400, color: _C.sub,
            ),
          ),
          TextSpan(
            text: 'Se connecter',
            style: GoogleFonts.dmSans(
              fontSize: 13.5, fontWeight: FontWeight.w700, color: _C.green,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.of(context).pop(),
          ),
        ]),
      ),
    );
  }
}