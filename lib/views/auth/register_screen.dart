import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/doodle_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSocialLoading = false;
  String _socialPlatform = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      role: 'user',
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Akun Anda sudah aktif.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isSocialLoading = true;
      _socialPlatform = 'Google';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;
    setState(() {
      _isSocialLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _signUpAnonymously() async {
    setState(() {
      _isSocialLoading = true;
      _socialPlatform = 'Tamu';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInAnonymously();

    if (!mounted) return;
    setState(() {
      _isSocialLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat datang! Anda masuk sebagai Tamu.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _socialSignUp(String platform) async {
    if (platform == 'Google') {
      await _signUpWithGoogle();
      return;
    }

    setState(() {
      _isSocialLoading = true;
      _socialPlatform = platform;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() {
      _isSocialLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daftar dengan $platform belum diaktifkan.'),
        backgroundColor: Colors.orange,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    // Theme colors
    final primaryTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final secondaryTextColor = isDarkBg ? const Color(0xFF9E9EAF) : const Color(0xFF707070);
    final cardBgColor = isDarkBg ? const Color(0xFF1E1E38).withOpacity(0.85) : Colors.white.withOpacity(0.90);
    final cardBorderColor = isDarkBg ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.85);
    final accentColor = isDarkBg ? const Color(0xFFA5B4FC) : const Color(0xFF6C63FF);
    final fieldBorderColor = isDarkBg ? Colors.white24 : Colors.black12;
    final inputStyle = TextStyle(color: isDarkBg ? Colors.white : Colors.black87);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: DoodleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Text(
                      'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mulai pantau kesehatan mentalmu hari ini!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Translucent Card (Chubby & Cute)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(color: cardBorderColor, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.06),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Input (Chubby)
                          TextFormField(
                            controller: _nameController,
                            style: inputStyle,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              labelStyle: TextStyle(fontSize: 13, color: secondaryTextColor),
                              prefixIcon: Icon(Icons.person_outline_rounded, color: accentColor, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 1.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Email Input (Chubby)
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: inputStyle,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(fontSize: 13, color: secondaryTextColor),
                              prefixIcon: Icon(Icons.email_outlined, color: accentColor, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 1.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!value.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Password Input (Chubby)
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: inputStyle,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(fontSize: 13, color: secondaryTextColor),
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: accentColor, size: 20),
                              suffixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: accentColor,
                                    size: 22,
                                  ),
                                  tooltip: _obscurePassword ? 'Tampilkan password' : 'Sembunyikan password',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 1.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password Input (Chubby)
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: inputStyle,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              labelStyle: TextStyle(fontSize: 13, color: secondaryTextColor),
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: accentColor, size: 20),
                              suffixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: accentColor,
                                    size: 22,
                                  ),
                                  tooltip: _obscureConfirmPassword ? 'Tampilkan password' : 'Sembunyikan password',
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 1.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(color: accentColor, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Submit Button (Chubby)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: authProvider.status == AuthStatus.authenticating || _isSocialLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: isDarkBg ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                elevation: 0,
                              ),
                              child: authProvider.status == AuthStatus.authenticating
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: isDarkBg ? Colors.black : Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Daftar Akun Baru',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkBg ? Colors.black : Colors.white),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Custom Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: isDarkBg ? Colors.white12 : Colors.black12, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('atau daftar dengan', style: TextStyle(color: isDarkBg ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
                              ),
                              Expanded(child: Divider(color: isDarkBg ? Colors.white12 : Colors.black12, thickness: 1)),
                            ],
                          ),
                          
                          const SizedBox(height: 16),

                          // Social Media buttons (Chubby)
                          Row(
                            children: [
                              // Google
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: authProvider.status == AuthStatus.authenticating || _isSocialLoading
                                        ? null
                                        : () => _socialSignUp('Google'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: isDarkBg ? Colors.white24 : Colors.black12, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: (_isSocialLoading && _socialPlatform == 'Google')
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Row(
                                             mainAxisAlignment: MainAxisAlignment.center,
                                             children: [
                                               Image.asset(
                                                 'assets/images/google.png',
                                                 height: 20,
                                                 width: 20,
                                                 fit: BoxFit.contain,
                                               ),
                                               const SizedBox(width: 8),
                                               Text('Google', style: TextStyle(color: primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                             ],
                                           ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Masuk Tamu (Guest Login)
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: authProvider.status == AuthStatus.authenticating || _isSocialLoading
                                        ? null
                                        : _signUpAnonymously,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: isDarkBg ? Colors.white24 : Colors.black12, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.account_circle_outlined, color: isDarkBg ? const Color(0xFFA5B4FC) : Colors.blueAccent, size: 20),
                                        const SizedBox(width: 6),
                                        Text('Masuk Tamu', style: TextStyle(color: primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
