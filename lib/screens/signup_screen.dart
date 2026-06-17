import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/auth_service.dart';
import '../data/favorite_service.dart';
import '../theme/app_theme.dart';
import 'main_navigator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await AuthService().register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
      return;
    }

    FavoriteService().loadFavorites();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigator()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1200&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildForm(),
                            const SizedBox(height: 24),
                            if (_errorMessage != null) _buildError(),
                            if (_errorMessage != null) const SizedBox(height: 16),
                            _buildSignupButton(),
                            const SizedBox(height: 32),
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Daftar Akun',
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mari bergabung dan temukan tempat tinggal impianmu.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nama Lengkap'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.dmSans(color: Colors.white),
          decoration: _inputDecoration(hint: 'John Doe', icon: Icons.person_outline_rounded),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
            if (v.trim().length < 3) return 'Nama minimal 3 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Email'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.dmSans(color: Colors.white),
          decoration: _inputDecoration(hint: 'contoh@email.com', icon: Icons.email_outlined),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
            if (!v.contains('@')) return 'Format email tidak valid';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Nomor Telepon'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.dmSans(color: Colors.white),
          decoration: _inputDecoration(hint: '08123456789', icon: Icons.phone_outlined),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Nomor telepon tidak boleh kosong';
            if (v.trim().length < 10) return 'Nomor telepon tidak valid';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Password'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.dmSans(color: Colors.white),
          decoration: _inputDecoration(hint: '••••••••', icon: Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
            if (v.length < 6) return 'Password minimal 6 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Konfirmasi Password'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSignup(),
          style: GoogleFonts.dmSans(color: Colors.white),
          decoration: _inputDecoration(hint: '••••••••', icon: Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
            if (v != _passwordController.text) return 'Password tidak cocok';
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB00020).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              )
            : Text(
                'Buat Akun',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sudah punya akun? ',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Masuk',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
