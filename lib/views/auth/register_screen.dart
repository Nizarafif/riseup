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
  bool _obscureText = true;
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
          content: Text('Pendaftaran berhasil! Silakan masuk.'),
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

  void _socialSignUp(String platform, String email) async {
    setState(() {
      _isSocialLoading = true;
      _socialPlatform = platform;
    });

    // Simulasi verifikasi media sosial
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(email, 'password');

    if (!mounted) return;
    setState(() {
      _isSocialLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil mendaftar & masuk via $platform!'),
          backgroundColor: const Color(0xFF00C9A7),
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

  void _showPhoneSignUpDialog() {
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
                  Text('Daftar No. Telepon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      _socialSignUp('No. Telepon', 'user@riseup.com');
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3F3D56)),
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

                    const Text(
                      'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F3D56),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mulai pantau kesehatan mentalmu hari ini!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF707070),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Translucent Card (Chubby & Cute)
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
                          // Name Input (Chubby)
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF6C63FF), size: 20),
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
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF6C63FF), size: 20),
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
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF6C63FF), size: 20),
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
                                      'Daftar Akun Baru',
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
                                child: Text('atau daftar dengan', style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
                              ),
                              Expanded(child: Divider(color: Colors.black12, thickness: 1)),
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
                                        : () => _socialSignUp('Google', 'user@riseup.com'),
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
                                        : _showPhoneSignUpDialog,
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
