import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../models/mood_model.dart';
import '../../models/history_model.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
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
          tabs: const [
            Tab(icon: Icon(Icons.show_chart_rounded), text: 'Grafik Tren Mood'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Riwayat Tes Pakar'),
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

    // Convert moods to FlSpot data
    final spots = moods.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.moodLevel.toDouble());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Perkembangan Suasana Hati',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Grafik di bawah ini menunjukkan pergerakan emosi harian Anda secara kronologis.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Chart Container
          Container(
            height: 250,
            padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
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
                    return const FlLine(color: Colors.black12, strokeWidth: 1);
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
                        if (idx >= 0 && idx < moods.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(moods[idx].tanggal),
                              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
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
                        String label = '';
                        switch (value.toInt()) {
                          case 1:
                            label = '😢';
                            break;
                          case 2:
                            label = '🙁';
                            break;
                          case 3:
                            label = '😐';
                            break;
                          case 4:
                            label = '🙂';
                            break;
                          case 5:
                            label = '😄';
                            break;
                        }
                        return Text(
                          label,
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (moods.length - 1).toDouble(),
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withOpacity(0.2),
                          const Color(0xFF00C9A7).withOpacity(0.0),
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
          const Text(
            'Catatan Jurnal Mood Terbaru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length > 5 ? 5 : moods.length,
            itemBuilder: (context, index) {
              // Show latest first
              final mood = moods[moods.length - 1 - index];
              String moodString = '';
              String moodEmoji = '';
              Color moodColor = Colors.grey;

              switch (mood.moodLevel) {
                case 1:
                  moodString = 'Sangat Buruk';
                  moodEmoji = '😢';
                  moodColor = Colors.red;
                  break;
                case 2:
                  moodString = 'Buruk';
                  moodEmoji = '🙁';
                  moodColor = Colors.orange;
                  break;
                case 3:
                  moodString = 'Normal';
                  moodEmoji = '😐';
                  moodColor = Colors.blue;
                  break;
                case 4:
                  moodString = 'Baik';
                  moodEmoji = '🙂';
                  moodColor = Colors.teal;
                  break;
                case 5:
                  moodString = 'Sangat Baik';
                  moodEmoji = '😄';
                  moodColor = Colors.green;
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Text(moodEmoji, style: const TextStyle(fontSize: 28)),
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
                                style: const TextStyle(fontSize: 11, color: Colors.black38),
                              ),
                            ],
                          ),
                          if (mood.catatan.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              mood.catatan,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF505050), height: 1.3),
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

  Widget _buildHistoryTab() {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final historyList = diagnosticProvider.historyList;

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

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final history = historyList[index];
        final isNormal = history.diagnosisCode == 'P000';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isNormal ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
                color: isNormal ? Colors.green[800] : Colors.red[800],
              ),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy, HH:mm').format(history.tanggal),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    
                    // Gejala terpilih
                    const Text(
                      'Gejala yang Anda laporkan:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: history.gejalaDipilih.map((code) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            code,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    const Text(
                      'Deskripsi Gangguan:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      history.deskripsi,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF505050), height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Solusi
                    const Text(
                      'Rekomendasi Pakar:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
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
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF3F3D56), height: 1.3),
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
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3F3D56)),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
