import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../login_screen.dart';

class GuestRedirectDialog extends StatelessWidget {
  const GuestRedirectDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GuestRedirectDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final primaryTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final secondaryTextColor = isDarkBg
        ? const Color(0xFF9E9EAF)
        : const Color(0xFF707070);
    final accentColor = isDarkBg
        ? const Color(0xFFA5B4FC)
        : const Color(0xFF6C63FF);
    final buttonColor = isDarkBg
        ? const Color(0xFF00C9A7)
        : const Color(0xFF6C63FF);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: dialogBgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDarkBg
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.9),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [buttonColor, buttonColor.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  // Cute lock/user icon with dynamic background
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_person_rounded,
                        color: accentColor,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Friendly title in slang
                  Text(
                    'Eits, Bentar Dulu! 🛑',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: primaryTextColor,
                      fontSize: 20,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Slang text explanation
                  Text(
                    'Upsss! Biar kamu bisa nikmatin semua fitur seru lainnya di RiseUp (kayak Pemantauan Tren, Napas Lega, Baca Buku, Peta Pakar, dll), kamu kudu daftar akun dulu nih. Yuk join sekarang, gampang banget kok!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Actions buttons
                  Row(
                    children: [
                      // Cancel Button ("Nanti Aja")
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: secondaryTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Nanti Aja',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Action Button ("Daftar Sekarang")
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                buttonColor,
                                buttonColor.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: buttonColor.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Bersihkan tumpukan navigasi kembali ke root (AuthWrapper) agar tidak numpuk
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                              LoginScreen.autoPushRegister = true;
                              await authProvider.signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Daftar Yuk!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
