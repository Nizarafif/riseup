import 'dart:ui' show ImageFilter;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/mood_theme_helper.dart';
import '../../models/mood_model.dart';
import '../music/ambient_music_sheet.dart';
import '../home/widgets/breathing_modal.dart';
import '../screening/map_webview_screen.dart';


class MonitoringScreen extends StatefulWidget {
  final bool isEmbedded;
  const MonitoringScreen({super.key, this.isEmbedded = false});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    // Sinkronisasi data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<MoodProvider>(context, listen: false).fetchMoods(user.uid);
        Provider.of<DiagnosticProvider>(context, listen: false).fetchHistory(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDarkBg 
                        ? const Color(0xFF1E1E38).withOpacity(0.5) 
                        : Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkBg ? Colors.white10 : Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Sliding background indicator
                      AnimatedAlign(
                        alignment: _tabController.index == 0 
                            ? Alignment.centerLeft 
                            : Alignment.centerRight,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDarkBg 
                                  ? const Color(0xFF6C63FF) 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Tab buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tabController.animateTo(0);
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.show_chart_rounded,
                                      size: 18,
                                      color: _tabController.index == 0
                                          ? (isDarkBg ? Colors.white : const Color(0xFF6C63FF))
                                          : (isDarkBg ? Colors.white38 : Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tren Mood',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _tabController.index == 0
                                            ? (isDarkBg ? Colors.white : const Color(0xFF6C63FF))
                                            : (isDarkBg ? Colors.white38 : Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tabController.animateTo(1);
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 18,
                                      color: _tabController.index == 1
                                          ? (isDarkBg ? Colors.white : const Color(0xFF6C63FF))
                                          : (isDarkBg ? Colors.white38 : Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Riwayat Tes',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _tabController.index == 1
                                            ? (isDarkBg ? Colors.white : const Color(0xFF6C63FF))
                                            : (isDarkBg ? Colors.white38 : Colors.grey[600]),
                                      ),
                                    ),
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
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMoodChartTab(),
            _buildHistoryTab(),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pemantauan Kondisi',
          style: TextStyle(color: Color(0xFF3F3D56), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3F3D56)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6C63FF),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.show_chart_rounded, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Tren Mood',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history_rounded, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Riwayat Tes',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoodChartTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildMoodChartTab() {
    final moodProvider = Provider.of<MoodProvider>(context);
    final moods = moodProvider.moods;
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final paletteIdx = authProvider.selectedPaletteIndex;
    final emojiThemeIdx = authProvider.selectedEmojiThemeIndex;
    final colorMid = MoodThemeHelper.getMoodColor(paletteIdx, 3);
    final colorMax = MoodThemeHelper.getMoodColor(paletteIdx, 5);

    if (moodProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (moods.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bubble_chart_outlined,
        title: 'Belum Ada Catatan Mood',
        description: 'Kembali ke dashboard utama untuk mulai mencatat mood harian Anda secara rutin agar dapat dipantau di sini.',
      );
    }

    // Group moods by unique date (yyyy-MM-dd) and keep only the latest entry per day
    final Map<String, MoodModel> uniqueDayMoods = {};
    for (final mood in moods) {
      final dateKey = DateFormat('yyyy-MM-dd').format(mood.tanggal);
      uniqueDayMoods[dateKey] = mood;
    }

    final displayMoods = uniqueDayMoods.values.toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    // Convert displayMoods to FlSpot data
    final spots = displayMoods.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.moodLevel.toDouble());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren Perkembangan Suasana Hati',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Grafik di bawah ini menunjukkan pergerakan emosi harian Anda secara kronologis.',
            style: TextStyle(
              fontSize: 12, 
              color: isDarkBg ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Chart Container
          Container(
            height: 250,
            padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
            decoration: BoxDecoration(
              color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkBg ? Colors.white10 : Colors.transparent,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkBg ? 0.2 : 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDarkBg ? Colors.white10 : Colors.black12, 
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < displayMoods.length) {
                          // Prevent title overlapping by checking length
                          bool showLabel = false;
                          if (displayMoods.length <= 7) {
                            showLabel = true;
                          } else if (displayMoods.length <= 14) {
                            showLabel = idx % 2 == 0;
                          } else if (displayMoods.length <= 21) {
                            showLabel = idx % 3 == 0;
                          } else {
                            showLabel = idx % 5 == 0;
                          }

                          if (!showLabel) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(displayMoods[idx].tanggal),
                              style: TextStyle(
                                fontSize: 9, 
                                color: isDarkBg ? Colors.white54 : Colors.grey, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final val = value.toInt();
                        if (val >= 1 && val <= 5) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: MoodEmojiWidget(
                              level: val,
                              size: 20,
                              paletteIndex: paletteIdx,
                              emojiThemeIndex: emojiThemeIdx,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: displayMoods.length > 1 ? (displayMoods.length - 1).toDouble() : 1.0,
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [colorMid, colorMax],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colorMid.withOpacity(0.25),
                          colorMax.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mood logs list
          Text(
            'Catatan Jurnal Mood Terbaru',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length > 30 ? 30 : moods.length,
            itemBuilder: (context, index) {
              // Show latest first
              final mood = moods[moods.length - 1 - index];
              final moodString = MoodThemeHelper.getMoodName(mood.moodLevel);
              final moodColor = MoodThemeHelper.getMoodColor(paletteIdx, mood.moodLevel);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkBg ? Colors.white10 : Colors.transparent,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.01), 
                      blurRadius: 5, 
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    MoodEmojiWidget(
                      level: mood.moodLevel,
                      size: 38,
                      paletteIndex: paletteIdx,
                      emojiThemeIndex: emojiThemeIdx,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                moodString,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: moodColor),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy').format(mood.tanggal),
                                style: TextStyle(
                                  fontSize: 11, 
                                  color: isDarkBg ? Colors.white54 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                          if (mood.catatan.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              mood.catatan,
                              style: TextStyle(
                                fontSize: 13, 
                                color: isDarkBg ? Colors.white70 : const Color(0xFF505050), 
                                height: 1.3,
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildTrendAnalysisCard(BuildContext context, DiagnosticProvider diagnosticProvider, bool isDarkBg) {
    final trend = diagnosticProvider.evaluate30DayScreeningTrend();
    if (trend['status'] == 'no_data') return const SizedBox.shrink();

    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final bodyColor = isDarkBg ? Colors.white70 : const Color(0xFF505050);
    final borderColor = isDarkBg
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF6C63FF).withOpacity(0.05);

    final Color statusColor = trend['color'] ?? Colors.grey;
    final IconData statusIcon = trend['icon'] ?? Icons.info_outline;

    final String status = trend['status'] ?? '';
    final bool isBad = status == 'worsening' || status == 'stable_bad';
    final bool isGood = status == 'stable_normal' || status == 'improving';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trend['title'] ?? 'Tren Kondisi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Analisis Tren 30 Hari',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkBg ? Colors.white54 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pattern label
          Row(
            children: [
              Text(
                'Arah Perkembangan: ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkBg ? Colors.white54 : Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend['pattern'] ?? '-',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trend['message'] ?? '',
            style: TextStyle(
              fontSize: 13,
              color: bodyColor,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (trend['actions'] != null && (trend['actions'] as List).isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: isDarkBg ? Colors.white10 : Colors.black12, height: 1),
            const SizedBox(height: 14),
            Text(
              'Rekomendasi Tindakan:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: (trend['actions'] as List<dynamic>).map((action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: statusColor, size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          action as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: bodyColor,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          if (isBad || isGood) ...[
            const SizedBox(height: 16),
            Divider(color: isDarkBg ? Colors.white10 : Colors.black12, height: 1),
            const SizedBox(height: 16),
          ],
          if (isBad) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MapWebviewScreen(
                        url: 'https://www.google.com/maps/search/?api=1&query=psikolog+dan+psikiater+terdekat',
                        title: 'Peta Psikolog & Psikiater',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Cari Psikolog / Psikiater Terdekat (Peta Pakar)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
          if (isGood) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const BreathingModal(),
                        );
                      },
                      icon: const Icon(Icons.spa_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Napas Lega',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AmbientMusicSheet(),
                        );
                      },
                      icon: const Icon(Icons.music_note_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Melodi Damai',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final historyList = diagnosticProvider.historyList;
    final isDarkBg = Provider.of<AuthProvider>(context).selectedBackgroundThemeIndex == 2;

    if (diagnosticProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_toggle_off_rounded,
        title: 'Belum Ada Riwayat Tes',
        description: 'Anda belum pernah melakukan tes kesehatan mental dengan sistem pakar. Mulai tes baru di beranda aplikasi.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildTrendAnalysisCard(context, diagnosticProvider, isDarkBg),
        ...historyList.map((history) {
          final isNormal = history.diagnosisCode == 'P000';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkBg ? Colors.white10 : Colors.transparent,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.01), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: isDarkBg ? Colors.white70 : Colors.grey,
                collapsedIconColor: isDarkBg ? Colors.white70 : Colors.grey,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isNormal 
                        ? Colors.green.withOpacity(isDarkBg ? 0.18 : 0.1) 
                        : Colors.red.withOpacity(isDarkBg ? 0.18 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isNormal ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                    color: isNormal ? Colors.green : Colors.redAccent,
                  ),
                ),
                title: Text(
                  history.hasilDiagnosis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isNormal 
                        ? (isDarkBg ? Colors.green[200] : Colors.green[800]) 
                        : (isDarkBg ? Colors.red[200] : Colors.red[800]),
                  ),
                ),
                subtitle: Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(history.tanggal),
                  style: TextStyle(
                    fontSize: 11, 
                    color: isDarkBg ? Colors.white54 : Colors.grey,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(height: 1, color: isDarkBg ? Colors.white10 : Colors.black12),
                        const SizedBox(height: 12),
                        
                        // Gejala terpilih
                        Text(
                          'Gejala yang Anda laporkan:',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            color: isDarkBg ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: history.gejalaDipilih.map((code) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(isDarkBg ? 0.18 : 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                code,
                                style: TextStyle(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold, 
                                  color: isDarkBg ? Colors.white : const Color(0xFF6C63FF),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
    
                        // Deskripsi
                        Text(
                          'Deskripsi Gangguan:',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            color: isDarkBg ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          history.deskripsi,
                          style: TextStyle(
                            fontSize: 13, 
                            color: isDarkBg ? Colors.white70 : const Color(0xFF505050), 
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
    
                        // Solusi
                        Text(
                          'Rekomendasi Pakar:',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            color: isDarkBg ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          children: history.solusi.map((sol) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.arrow_right_rounded, color: Color(0xFF6C63FF), size: 18),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      sol,
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: isDarkBg ? Colors.white70 : const Color(0xFF3F3D56), 
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDarkBg = Provider.of<AuthProvider>(context, listen: false).selectedBackgroundThemeIndex == 2;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: isDarkBg ? Colors.white38 : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkBg ? Colors.white54 : Colors.grey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
