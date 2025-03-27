import 'package:flutter/material.dart';
import '../../utils/tab_utils.dart';

class MatchStats extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;

  const MatchStats({required this.statsFuture, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabUtils.buildTabContent(
      future: statsFuture,
      builder: (data) => _buildStatsContent(data),
      emptyMessage: "Không có thống kê trận đấu",
      errorMessage: "Lỗi khi tải thống kê",
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats) {
    final homeStats = stats['home'] ?? {};
    final awayStats = stats['away'] ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatComparison('KIỂM SOÁT BÓNG',
            homeStats['possession'], awayStats['possession'], isPercentage: true),
        _buildStatComparison('TỔNG CÚ SÚT',
            homeStats['totalShots'], awayStats['totalShots']),
        _buildStatComparison('SÚT TRÚNG ĐÍCH',
            homeStats['shotsOnTarget'], awayStats['shotsOnTarget']),
        _buildStatComparison('ĐƯỜNG CHUYỀN',
            homeStats['totalPasses'], awayStats['totalPasses']),
        _buildStatComparison('PHẠM LỖI',
            homeStats['fouls'], awayStats['fouls']),
        _buildStatComparison('THẺ VÀNG',
            homeStats['yellowCards'], awayStats['yellowCards']),
        _buildStatComparison('THẺ ĐỎ',
            homeStats['redCards'], awayStats['redCards']),
      ],
    );
  }

  Widget _buildStatComparison(
      String label,
      dynamic homeValue,
      dynamic awayValue, {
        bool isPercentage = false,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            if (isPercentage)
              _buildProgressComparison(homeValue, awayValue)
            else
              _buildValueComparison(homeValue, awayValue),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressComparison(dynamic homeValue, dynamic awayValue) {
    final homeProgress = (double.tryParse(homeValue?.toString() ?? '0') ?? 0) / 100;
    final awayProgress = (double.tryParse(awayValue?.toString() ?? '0') ?? 0) / 100;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: homeProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 10,
              ),
              const SizedBox(height: 4),
              Text(
                '${homeValue ?? '0'}%',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: awayProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
                minHeight: 10,
              ),
              const SizedBox(height: 4),
              Text(
                '${awayValue ?? '0'}%',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueComparison(dynamic homeValue, dynamic awayValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          homeValue?.toString() ?? '-',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "VS",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(
          awayValue?.toString() ?? '-',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}