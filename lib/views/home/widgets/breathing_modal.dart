import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class BreathingModal extends StatefulWidget {
  const BreathingModal({super.key});

  @override
  State<BreathingModal> createState() => _BreathingModalState();
}

class _BreathingModalState extends State<BreathingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _guideText = "Tarik Napas";
  int _counter = 4;

  @override
  void initState() {
    super.initState();
    // 16-second box breathing cycle:
    // 4s Inhale, 4s Hold, 4s Exhale, 4s Hold
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _animation = TweenSequence<double>([
      // Tarik napas: membesar dari 1.0 ke 1.8 (4s)
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.8,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // Tahan: tetap besar (4s)
      TweenSequenceItem(tween: ConstantTween(1.8), weight: 25),
      // Hembuskan: mengecil kembali ke 1.0 (4s)
      TweenSequenceItem(
        tween: Tween(
          begin: 1.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // Tahan: tetap kecil (4s)
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 25),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      }
    });

    _controller.addListener(() {
      final double progress = _controller.value;
      String newText = "Tarik Napas";
      int newSecs = 4;

      if (progress < 0.25) {
        newText = "Tarik Napas";
        newSecs = 4 - ((progress * 16) % 4).floor();
      } else if (progress < 0.50) {
        newText = "Tahan Napas";
        newSecs = 4 - (((progress - 0.25) * 16) % 4).floor();
      } else if (progress < 0.75) {
        newText = "Hembuskan Napas";
        newSecs = 4 - (((progress - 0.50) * 16) % 4).floor();
      } else {
        newText = "Tahan Napas";
        newSecs = 4 - (((progress - 0.75) * 16) % 4).floor();
      }

      if (_guideText != newText || _counter != newSecs) {
        setState(() {
          _guideText = newText;
          _counter = newSecs;
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final bgColor = isDarkBg ? const Color(0xFF16162D) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white54 : Colors.grey;
    final guideTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final techTextColor = isDarkBg ? Colors.white38 : Colors.black38;
    final closeIconColor = isDarkBg ? Colors.white70 : Colors.black54;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: isDarkBg
            ? Border.all(color: Colors.white.withOpacity(0.08), width: 1)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latihan Relaksasi Napas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: closeIconColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ikuti lingkaran pemandu di bawah ini untuk menstabilkan pernapasan dan detak jantung Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.4),
          ),
          const Spacer(),

          // Animated breathing circles
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double val = _animation.value;
                final ringColor = isDarkBg
                    ? const Color(0xFF00C9A7)
                    : const Color(0xFF6C63FF);
                final gradientColors = isDarkBg
                    ? [const Color(0xFF00C9A7), const Color(0xFF0088A9)]
                    : [const Color(0xFF6C63FF), const Color(0xFF8F8AFF)];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring glow effect
                    Container(
                      height: 120 * val,
                      width: 120 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withOpacity(
                          0.08 * (val - 0.5).clamp(0, 1),
                        ),
                      ),
                    ),
                    // Middle ring
                    Container(
                      height: 90 * val,
                      width: 90 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withOpacity(0.15),
                      ),
                    ),
                    // Inner solid circle
                    Container(
                      height: 70 * val,
                      width: 70 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ringColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_counter',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Text(
            _guideText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: guideTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Teknik Box Breathing (Kotak 4-4-4-4)',
            style: TextStyle(color: techTextColor, fontSize: 12),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkBg
                    ? const Color(0xFF00C9A7)
                    : const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
