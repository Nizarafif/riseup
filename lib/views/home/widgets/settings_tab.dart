import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import '../../../providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../onboarding/palette_setup_screen.dart';
import 'avatar_helper.dart';

class SettingsTab extends StatelessWidget {
  final UserModel user;
  const SettingsTab({super.key, required this.user});

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:')) {
      return NetworkImage(path);
    }
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      return FileImage(io.File(path));
    }
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: authProvider.selectedReminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF3F3D56),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      authProvider.completeReminderSetup(picked);
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(
      text: authProvider.user?.name ?? '',
    );
    final photoUrlController = TextEditingController(
      text: authProvider.user?.photoUrl ?? '',
    );
    int selectedAvatarIndex = authProvider.user?.avatarIndex ?? 0;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
            final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
            final subtitleColor = isDarkBg
                ? Colors.white70
                : const Color(0xFF707070);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkBg ? const Color(0xFF16162D) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDarkBg ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ubah Profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Pilih Avatar Bawaan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: presetAvatars.length,
                          itemBuilder: (context, idx) {
                            final isSelected =
                                selectedAvatarIndex == idx &&
                                photoUrlController.text.trim().isEmpty;
                            final avatar = presetAvatars[idx];

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedAvatarIndex = idx;
                                  photoUrlController.clear();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 56,
                                margin: const EdgeInsets.only(
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: avatar.gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6C63FF)
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF6C63FF,
                                            ).withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: Text(
                                    avatar.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Foto Profil Kustom',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDarkBg
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xFFF8F9FD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: photoUrlController.text.trim().isNotEmpty
                                    ? const Color(0xFF6C63FF)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              image: photoUrlController.text.trim().isNotEmpty
                                  ? DecorationImage(
                                      image: _getImageProvider(
                                        photoUrlController.text.trim(),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoUrlController.text.trim().isEmpty
                                ? Icon(
                                    Icons.no_photography_outlined,
                                    color: textColor.withOpacity(0.4),
                                    size: 24,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );
                                    if (image != null) {
                                      setModalState(() {
                                        photoUrlController.text = image.path;
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.photo_library_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Pilih dari Galeri',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF6C63FF,
                                    ).withOpacity(0.12),
                                    foregroundColor: const Color(0xFF6C63FF),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                                if (photoUrlController.text
                                    .trim()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  TextButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        photoUrlController.clear();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    label: const Text(
                                      'Hapus Foto Kustom',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nama Pengguna',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nama Lengkap',
                          hintStyle: TextStyle(
                            color: subtitleColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: isDarkBg
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xFFF8F9FD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDarkBg
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.04),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6C63FF),
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (value.trim().length < 2) {
                            return 'Nama minimal terdiri dari 2 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDarkBg
                                      ? Colors.white30
                                      : Colors.grey.withOpacity(0.3),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setModalState(() {
                                          isSaving = true;
                                        });

                                        final success = await authProvider
                                            .updateProfile(
                                              nameController.text.trim(),
                                              selectedAvatarIndex,
                                              photoUrlController.text.trim(),
                                            );

                                        if (success) {
                                          if (dialogCtx.mounted) {
                                            Navigator.pop(dialogCtx);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Profil berhasil diperbarui!',
                                                ),
                                                backgroundColor: Color(
                                                  0xFF00C9A7,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          setModalState(() {
                                            isSaving = false;
                                          });
                                          if (dialogCtx.mounted) {
                                            ScaffoldMessenger.of(
                                              dialogCtx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Gagal memperbarui profil.',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white60 : const Color(0xFF707070);
    final iconColor = isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF);
    final defaultTrailingColor = isDarkBg ? Colors.white30 : Colors.black26;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkBg
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFF6C63FF).withOpacity(0.04),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkBg ? 0.25 : 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.5, color: subtitleColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: defaultTrailingColor,
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }

  // --- Unused Helper Widgets from original code ---
  Widget _buildAdminStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkBg
              ? Colors.white10
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkBg
                ? Colors.white10
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isPremium = authProvider.isPremium;
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, authProvider),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDarkBg
                      ? Colors.white10
                      : Colors.black12.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  user.photoUrl.isNotEmpty
                      ? Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkBg
                                  ? const Color(0xFF00C9A7)
                                  : const Color(0xFF6C63FF),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              image: _getImageProvider(user.photoUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: presetAvatars[user.avatarIndex]
                                  .gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: presetAvatars[user.avatarIndex]
                                    .gradientColors[0]
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              presetAvatars[user.avatarIndex].emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkBg
                                ? Colors.white
                                : const Color(0xFF3F3D56),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkBg ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? const Color(0xFFFFD54F).withOpacity(0.2)
                                : isDarkBg
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPremium ? '👑 Premium Member' : 'Standard Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPremium
                                  ? const Color(0xFFFFD54F)
                                  : isDarkBg
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Kustomisasi & Tema',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkBg ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.palette_outlined,
            title: 'Kustomisasi Palet Warna & Emoji',
            subtitle: 'Ubah skema warna mood dan emoji Anda',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PaletteSetupScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.wallpaper_rounded,
            title: 'Tema Latar Belakang',
            subtitle: 'Pilih tipe dekorasi latar belakang',
            trailing: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
              ),
              child: DropdownButton<int>(
                value: authProvider.selectedBackgroundThemeIndex,
                underline: const SizedBox.shrink(),
                dropdownColor: isDarkBg
                    ? const Color(0xFF1E1E38)
                    : Colors.white,
                iconEnabledColor: isDarkBg
                    ? Colors.white70
                    : const Color(0xFF3F3D56),
                style: TextStyle(
                  color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(
                      'Doodle',
                      style: TextStyle(
                        color: isDarkBg
                            ? Colors.white
                            : const Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(
                      'Cairan',
                      style: TextStyle(
                        color: isDarkBg
                            ? Colors.white
                            : const Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(
                      'Malam',
                      style: TextStyle(
                        color: isDarkBg
                            ? Colors.white
                            : const Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    authProvider.updateBackgroundTheme(val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Notifikasi & Sistem',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkBg ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.access_time_rounded,
            title: 'Waktu Pengingat',
            subtitle: 'Atur jam notifikasi jurnal harian Anda',
            trailing: Text(
              authProvider.selectedReminderTime.format(context),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            onTap: () => _selectReminderTime(context, authProvider),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogCtx) {
                    final isDarkBg =
                        authProvider.selectedBackgroundThemeIndex == 2;
                    final dialogBgColor = isDarkBg
                        ? const Color(0xFF1E1E38)
                        : Colors.white;
                    final titleTextColor = isDarkBg
                        ? Colors.white
                        : const Color(0xFF3F3D56);
                    final subtitleTextColor = isDarkBg
                        ? Colors.white70
                        : const Color(0xFF707070);

                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: dialogBgColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDarkBg
                                ? Colors.white10
                                : Colors.black.withOpacity(0.05),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDarkBg ? 0.4 : 0.08,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Keluar dari RiseUp?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: titleTextColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sesi Anda akan berakhir. Tapi tenang, seluruh riwayat jurnal dan monitoring Anda tetap tersimpan dengan aman.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleTextColor,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(dialogCtx),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: isDarkBg
                                                ? Colors.white12
                                                : Colors.black12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(
                                            color: isDarkBg
                                                ? Colors.white70
                                                : const Color(0xFF505050),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(dialogCtx);
                                          authProvider.signOut();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Keluar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
