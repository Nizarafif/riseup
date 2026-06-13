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

  void _showPhoneLoginDialog() {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    bool isOtpSent = false;
    final formKey = GlobalKey<FormState>();
    CountryInfo selectedCountry = _countries[0]; // Default to Indonesia

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.phone_android_rounded, color: Color(0xFF6C63FF)),
                  SizedBox(width: 10),
                  Text('Masuk No. Telepon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isOtpSent) ...[
                      const Text(
                        'Masukkan nomor telepon Anda untuk menerima kode verifikasi OTP.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '81234567890',
                          prefixIcon: InkWell(
                            onTap: () {
                              _showCountryPickerBottomSheet(
                                context,
                                (CountryInfo country) {
                                  setState(() {
                                    selectedCountry = country;
                                  });
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedCountry.flag,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedCountry.code,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3F3D56)),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey, size: 20),
                                  const SizedBox(width: 4),
                                  Container(
                                    height: 20,
                                    width: 1,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          if (val.length < 8) {
                            return 'Nomor telepon tidak valid';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Kode OTP simulasi telah dikirim ke nomor Anda. Masukkan kode 123456 untuk masuk.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '******',
                          counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Kode OTP wajib diisi';
                          }
                          if (val != '123456') {
                            return 'Kode OTP salah (Gunakan 123456)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    if (!isOtpSent) {
                      setState(() {
                        isOtpSent = true;
                      });
                    } else {
                      Navigator.pop(context);
                      _socialLogin('No. Telepon');
                    }
                  },
                  child: Text(isOtpSent ? 'Verifikasi' : 'Kirim OTP'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.lock_reset_rounded, color: Color(0xFF6C63FF)),
                  SizedBox(width: 10),
                  Text('Reset Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Masukkan alamat email Anda untuk menerima link reset kata sandi.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
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
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          setDialogState(() {
                            isLoading = true;
                          });

                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Kirim Link'),
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

                    const Text(
                      'RiseUp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F3D56),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Raih Kembali Damai di Hatimu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF707070),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Translucent Form Card (Chubby & Cute)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.90),
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(color: Colors.white.withOpacity(0.85), width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.06),
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
                          const Text(
                            'Masuk Akun',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F3D56),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Email Field (Chubby)
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'nama@email.com',
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C63FF), size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(color: Colors.black12, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2.0),
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
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF6C63FF), size: 20),
                              suffixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF6C63FF),
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
                                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(color: Colors.black12, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2.0),
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
                                      activeColor: const Color(0xFF6C63FF),
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
                                  const Text(
                                    'Ingat Saya',
                                    style: TextStyle(
                                      color: Color(0xFF707070),
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
                                child: const Text(
                                  'Lupa kata sandi?',
                                  style: TextStyle(
                                    color: Color(0xFF6C63FF),
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
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                elevation: 0,
                              ),
                              child: authProvider.status == AuthStatus.authenticating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Custom Divider
                          Row(
                            children: const [
                              Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('atau login dengan', style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
                              ),
                              Expanded(child: Divider(color: Colors.black12, thickness: 1)),
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
                                      side: const BorderSide(color: Colors.black12, width: 1.5),
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
                                               const Text('Google', style: TextStyle(color: Color(0xFF3F3D56), fontSize: 13, fontWeight: FontWeight.bold)),
                                             ],
                                           ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Nomor Telepon (SMS OTP Demo)
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: authProvider.status == AuthStatus.authenticating || _isSocialLoading
                                        ? null
                                        : _showPhoneLoginDialog,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.black12, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.phone_android_rounded, color: Colors.blueAccent, size: 20),
                                        SizedBox(width: 6),
                                        Text('No. Telepon', style: TextStyle(color: Color(0xFF3F3D56), fontSize: 13, fontWeight: FontWeight.bold)),
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
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: Color(0xFF707070), fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
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

  void _showCountryPickerBottomSheet(BuildContext context, Function(CountryInfo) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Kode Negara',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(country.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Text(
                        country.code,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                      ),
                      onTap: () {
                        onSelected(country);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CountryInfo {
  final String name;
  final String code;
  final String flag;

  const CountryInfo({required this.name, required this.code, required this.flag});
}

const List<CountryInfo> _countries = [
  CountryInfo(name: 'Indonesia', code: '+62', flag: '🇮🇩'),
  CountryInfo(name: 'Malaysia', code: '+60', flag: '🇲🇾'),
  CountryInfo(name: 'Singapore', code: '+65', flag: '🇸🇬'),
  CountryInfo(name: 'United States', code: '+1', flag: '🇺🇸'),
  CountryInfo(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
  CountryInfo(name: 'Japan', code: '+81', flag: '🇯🇵'),
  CountryInfo(name: 'Australia', code: '+61', flag: '🇦🇺'),
  CountryInfo(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦'),
  CountryInfo(name: 'Thailand', code: '+66', flag: '🇹🇭'),
  CountryInfo(name: 'Philippines', code: '+63', flag: '🇵🇭'),
];
