import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class AmbientTrack {
  final String title;
  final String source;
  final bool isLocal;
  final bool isAsset;
  final String icon;

  AmbientTrack({
    required this.title,
    required this.source,
    required this.isLocal,
    this.isAsset = false,
    required this.icon,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'source': source,
    'isLocal': isLocal,
    'isAsset': isAsset,
    'icon': icon,
  };

  factory AmbientTrack.fromMap(Map<String, dynamic> map) => AmbientTrack(
    title: map['title'] ?? '',
    source: map['source'] ?? '',
    isLocal: map['isLocal'] ?? false,
    isAsset: map['isAsset'] ?? false,
    icon: map['icon'] ?? '🎵',
  );
}

class AmbientMusicSheet extends StatefulWidget {
  const AmbientMusicSheet({super.key});

  @override
  State<AmbientMusicSheet> createState() => _AmbientMusicSheetState();
}

class _AmbientMusicSheetState extends State<AmbientMusicSheet>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _rotationController;

  // Trek bawaan (instrumental lokal dari asset bundle)
  final List<AmbientTrack> _presetTracks = [
    AmbientTrack(
      title: 'Piano Meditasi',
      source: 'Audio/Piano_Meditasi.mp3',
      isLocal: false,
      isAsset: true,
      icon: '🧘',
    ),
    AmbientTrack(
      title: 'Melodi Hujan',
      source: 'Audio/Melodi_Hujan.mp3',
      isLocal: false,
      isAsset: true,
      icon: '🌧️',
    ),
    AmbientTrack(
      title: 'Hutan Damai',
      source: 'Audio/Hutan_Damai.mp3',
      isLocal: false,
      isAsset: true,
      icon: '🌲',
    ),
    AmbientTrack(
      title: 'Ombak Pantai',
      source: 'Audio/Ombak_Pantai.mp3',
      isLocal: false,
      isAsset: true,
      icon: '🌊',
    ),
  ];

  List<AmbientTrack> _customTracks = [];
  int _currentTrackIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 0.5;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _completionSub;

  List<AmbientTrack> get _allTracks => [..._presetTracks, ..._customTracks];
  AmbientTrack get _currentTrack => _allTracks[_currentTrackIndex];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _loadCustomTracks();
    _setupAudioListeners();
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _completionSub?.cancel();
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _setupAudioListeners() {
    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        final playing = state == PlayerState.playing;
        setState(() => _isPlaying = playing);
        if (playing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });

    _completionSub = _audioPlayer.onPlayerComplete.listen((_) {
      _playNext();
    });
  }

  Future<void> _loadCustomTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tracksJson = prefs.getString('custom_ambient_tracks');
      if (tracksJson != null) {
        final List<dynamic> decoded = json.decode(tracksJson);
        setState(() {
          _customTracks = decoded
              .map((item) => AmbientTrack.fromMap(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat musik kustom: $e");
    }
  }

  Future<void> _saveCustomTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _customTracks.map((t) => t.toMap()).toList(),
      );
      await prefs.setString('custom_ambient_tracks', encoded);
    } catch (e) {
      debugPrint("Gagal menyimpan musik kustom: $e");
    }
  }

  Future<void> _playTrack(int index) async {
    if (index < 0 || index >= _allTracks.length) return;

    setState(() {
      _currentTrackIndex = index;
      _isLoading = true;
    });

    try {
      await _audioPlayer.stop();
      final track = _allTracks[index];

      if (track.isAsset) {
        await _audioPlayer.play(AssetSource(track.source));
      } else if (track.isLocal) {
        await _audioPlayer.play(DeviceFileSource(track.source));
      } else {
        await _audioPlayer.play(UrlSource(track.source));
      }

      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memutar trek: ${e.toString().split(':').last.trim()}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePlay() async {
    if (_isLoading) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero) {
        await _playTrack(_currentTrackIndex);
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  Future<void> _stopPlay() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  void _playNext() {
    if (_allTracks.isEmpty) return;
    int nextIdx = (_currentTrackIndex + 1) % _allTracks.length;
    _playTrack(nextIdx);
  }

  void _playPrev() {
    if (_allTracks.isEmpty) return;
    int prevIdx =
        (_currentTrackIndex - 1 + _allTracks.length) % _allTracks.length;
    _playTrack(prevIdx);
  }

  Future<void> _addCustomMusic() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name.replaceAll(
          RegExp(r'\.[^.]+$'),
          '',
        ); // Bersihkan ekstensi

        final newTrack = AmbientTrack(
          title: name,
          source: path,
          isLocal: true,
          icon: '🎵',
        );

        setState(() {
          _customTracks.add(newTrack);
        });
        await _saveCustomTracks();

        // Putar trek baru secara otomatis
        final newIndex = _allTracks.length - 1;
        await _playTrack(newIndex);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batal atau Gagal memilih file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _deleteCustomTrack(int indexInCustom) async {
    // Cari index global trek yang akan dihapus
    final trackToDelete = _customTracks[indexInCustom];
    final globalIndex = _presetTracks.length + indexInCustom;

    // Jika sedang memutar lagu yang akan dihapus, hentikan dulu
    if (_currentTrackIndex == globalIndex) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
        _currentTrackIndex = 0;
      });
    } else if (_currentTrackIndex > globalIndex) {
      setState(() {
        _currentTrackIndex--;
      });
    }

    setState(() {
      _customTracks.removeAt(indexInCustom);
    });
    await _saveCustomTracks();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    final bgColor = isDarkBg
        ? const Color(0xFF13132B)
        : const Color(0xFFF8FAFC);
    final cardColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF1E293B);
    final textSubtitle = isDarkBg ? Colors.white70 : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF6C63FF);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Drag Bar
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkBg ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Judul Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Melodi Damai',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Musik & Ambient Relaksasi',
                          style: TextStyle(fontSize: 12, color: textSubtitle),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: textSubtitle,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Visual CD Player / Equalizer
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(isDarkBg ? 0.3 : 0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.8),
                            const Color(0xFFC084FC),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // CD Grooves
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // CD Center Hole
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgColor,
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _currentTrack.icon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul Lagu Sedang Diputar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _currentTrack.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                _currentTrack.isLocal
                    ? 'Musik Kustom Anda'
                    : 'Instrumen Relaksasi',
                style: TextStyle(fontSize: 12, color: textSubtitle),
              ),
              const SizedBox(height: 12),

              // Progress Bar (Slider Durasi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3.5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: isDarkBg
                            ? Colors.white10
                            : Colors.black12,
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration.inSeconds > 0
                            ? _duration.inSeconds.toDouble()
                            : 1.0,
                        value: _position.inSeconds.toDouble().clamp(
                          0.0,
                          _duration.inSeconds > 0
                              ? _duration.inSeconds.toDouble()
                              : 1.0,
                        ),
                        onChanged: (val) async {
                          await _audioPlayer.seek(
                            Duration(seconds: val.toInt()),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(fontSize: 11, color: textSubtitle),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(fontSize: 11, color: textSubtitle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Kontrol Pemutaran
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 26,
                    color: textColor,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: _playPrev,
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 26,
                    color: textColor,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: _playNext,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Slider Volume
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      _volume == 0
                          ? Icons.volume_mute_rounded
                          : _volume < 0.5
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                      color: textSubtitle,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 4.5,
                          ),
                          activeTrackColor: primaryColor.withOpacity(0.8),
                          inactiveTrackColor: isDarkBg
                              ? Colors.white10
                              : Colors.black12,
                          thumbColor: primaryColor,
                        ),
                        child: Slider(
                          value: _volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (val) async {
                            setState(() => _volume = val);
                            await _audioPlayer.setVolume(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.transparent, height: 16),

              // Bagian Daftar Lagu (List Tracks)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Trek Suara',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_to_photos_rounded, size: 16),
                      label: const Text(
                        'Kustom Musik',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: _addCustomMusic,
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Container List Lagu
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkBg
                        ? Colors.white10
                        : const Color(0xFF6C63FF).withOpacity(0.04),
                    width: 1.5,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allTracks.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDarkBg ? Colors.white10 : const Color(0xFFF1F5F9),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final track = _allTracks[index];
                    final isCurrent = index == _currentTrackIndex;

                    return ListTile(
                      onTap: () => _playTrack(index),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? primaryColor.withOpacity(0.1)
                              : isDarkBg
                              ? Colors.white.withOpacity(0.03)
                              : Colors.black.withOpacity(0.02),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          track.icon,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      title: Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrent ? primaryColor : textColor,
                        ),
                      ),
                      subtitle: Text(
                        track.isLocal ? 'Musik Lokal Anda' : 'Preset Ambient',
                        style: TextStyle(
                          fontSize: 10,
                          color: isCurrent
                              ? primaryColor.withOpacity(0.7)
                              : textSubtitle,
                        ),
                      ),
                      trailing: isCurrent && _isPlaying
                          ? Icon(
                              Icons.volume_up_rounded,
                              color: primaryColor,
                              size: 18,
                            )
                          : track.isLocal
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              color: Colors.redAccent.withOpacity(0.8),
                              onPressed: () => _deleteCustomTrack(
                                index - _presetTracks.length,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
