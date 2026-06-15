import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import 'widgets/doodle_background.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isSocialLoading = false;
  String _socialPlatform = '';
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final savedEmail = prefs.getString('saved_email') ?? '';
      if (rememberMe && savedEmail.isNotEmpty) {
        setState(() {
          _rememberMe = true;
          _emailController.text = savedEmail;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat status Ingat Saya: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setBool('remember_me', true);
          await prefs.setString('saved_email', _emailController.text.trim());
        } else {
          await prefs.remove('remember_me');
          await prefs.remove('saved_email');
        }
      } catch (e) {
        debugPrint('Gagal menyimpan status Ingat Saya: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
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

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _signInAnonymously() async {
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

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _socialLogin(String platform) async {
    if (platform == 'Google') {
      await _signInWithGoogle();
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
        content: Text('Masuk dengan $platform belum diaktifkan.'),
        backgroundColor: Colors.orange,
      ),
    );
  }



  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    
    final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final primaryTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final secondaryTextColor = isDarkBg ? const Color(0xFF9E9EAF) : Colors.grey;
    final accentColor = isDarkBg ? const Color(0xFFA5B4FC) : const Color(0xFF6C63FF);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: accentColor),
                  const SizedBox(width: 10),
                  Text('Reset Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Masukkan alamat email Anda untuk menerima link reset kata sandi.',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      style: TextStyle(color: primaryTextColor),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: secondaryTextColor),
                        prefixIcon: Icon(Icons.email_outlined, color: accentColor, size: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDarkBg ? Colors.white24 : Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accentColor, width: 2),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!val.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: accentColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: isDarkBg ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          setDialogState(() {
                            isLoading = true;
                          });

                          final success = await authProvider.sendPasswordResetEmail(resetEmailController.text);

                          if (!mounted) return;

                          setDialogState(() {
                            isLoading = false;
                          });

                          Navigator.pop(context);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Link reset kata sandi telah dikirim ke ${resetEmailController.text}!'),
                                backgroundColor: const Color(0xFF00C9A7),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.errorMessage.isNotEmpty 
                                    ? authProvider.errorMessage 
                                    : 'Gagal mengirim link reset kata sandi.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(color: isDarkBg ? Colors.black : Colors.white, strokeWidth: 2),
                        )
                      : Text('Kirim Link', style: TextStyle(color: isDarkBg ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
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
      body: DoodleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Text(
                      'RiseUp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Raih Kembali Damai di Hatimu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Translucent Form Card (Chubby & Cute)
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
                          Text(
                            'Masuk Akun',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Email Field (Chubby)
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: inputStyle,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'nama@email.com',
                              labelStyle: TextStyle(fontSize: 13, color: secondaryTextColor),
                              hintStyle: TextStyle(color: isDarkBg ? Colors.white30 : Colors.black38),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                          const SizedBox(height: 14),

                          // Password Field (Chubby)
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
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
                                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: accentColor,
                                    size: 22,
                                  ),
                                  tooltip: _obscureText ? 'Tampilkan password' : 'Sembunyikan password',
                                  onPressed: () {
                                    setState(() => _obscureText = !_obscureText);
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: accentColor,
                                      checkColor: isDarkBg ? Colors.black : Colors.white,
                                      side: BorderSide(color: isDarkBg ? Colors.white54 : Colors.black45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ingat Saya',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Lupa kata sandi?',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Login Submit Button (Chubby)
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
                                      'Masuk',
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
                                child: Text('atau login dengan', style: TextStyle(color: isDarkBg ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
                              ),
                              Expanded(child: Divider(color: isDarkBg ? Colors.white12 : Colors.black12, thickness: 1)),
                            ],
                          ),
                          
                          const SizedBox(height: 16),

                          // Social Media Sign-In buttons (Chubby)
                          Row(
                            children: [
                              // Google (Demo User)
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: authProvider.status == AuthStatus.authenticating || _isSocialLoading
                                        ? null
                                        : () => _socialLogin('Google'),
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
                                        : _signInAnonymously,
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
                    const SizedBox(height: 20),

                    // Navigation Link to Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: secondaryTextColor, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
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
