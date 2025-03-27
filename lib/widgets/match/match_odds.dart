import 'package:flutter/material.dart';
import '../../../core/match_odds_service.dart';
import '../../utils/match_utils.dart';

class MatchOdds extends StatelessWidget {
  final Map<String, dynamic> match;
  final MatchOddsService matchOddsService;

  const MatchOdds({
    required this.match,
    required this.matchOddsService,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final areaCode = match["competition"]?["area"]?["code"] as String? ?? "ENG";

    return FutureBuilder<Map<String, dynamic>>(
      future: matchOddsService.mapMatchOdds(match, areaCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Không có dữ liệu tỷ lệ cược'));
        }

        return _buildOddsContent(snapshot.data!);
      },
    );
  }

  Widget _buildOddsContent(Map<String, dynamic> matchOdds) {
    final odds = matchOdds['odds'];
    final homeTeamName = matchOdds['homeTeam'] as String;
    final awayTeamName = matchOdds['awayTeam'] as String;

    if (odds == 'No odds available' || odds is String) {
      return Center(child: Text(odds.toString()));
    }

    final bookmakers = odds['bookmakers'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '$homeTeamName vs $awayTeamName',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (bookmakers.isNotEmpty)
          ...bookmakers.map((bookmaker) {
            final markets = bookmaker['markets'] as List<dynamic>? ?? [];
            if (markets.isEmpty) return const SizedBox.shrink();

            final outcomes = markets[0]['outcomes'] as List<dynamic>? ?? [];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmaker['title'] ?? 'Nhà cái không xác định',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chủ nhà: ${outcomes.isNotEmpty ? outcomes[0]['price'] ?? '-' : '-'}'),
                        Text('Hòa: ${outcomes.length > 2 ? outcomes[2]['price'] ?? '-' : '-'}'),
                        Text('Khách: ${outcomes.length > 1 ? outcomes[1]['price'] ?? '-' : '-'}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList()
        else
          const Text('Không có nhà cái nào cung cấp tỷ lệ cược'),
      ],
    );
  }
}