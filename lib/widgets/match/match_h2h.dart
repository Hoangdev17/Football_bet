import 'package:flutter/material.dart';
import '../shared/team_info.dart';
import '../../utils/match_utils.dart';
import '../../utils/tab_utils.dart';

class MatchH2H extends StatelessWidget {
  final Future<Map<String, dynamic>> h2hFuture;

  const MatchH2H({required this.h2hFuture, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabUtils.buildTabContent(
      future: h2hFuture,
      builder: (data) => _buildH2HContent(data),
      emptyMessage: "Hai đội chưa từng đối đầu gần đây",
      errorMessage: "Lỗi khi tải dữ liệu đối đầu",
    );
  }

  Widget _buildH2HContent(Map<String, dynamic> data) {
    final matches = data["matches"] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final homeTeam = match["homeTeam"] ?? {};
        final awayTeam = match["awayTeam"] ?? {};
        final homeScore = match["score"]?["fullTime"]?["home"]?.toString() ?? "?";
        final awayScore = match["score"]?["fullTime"]?["away"]?.toString() ?? "?";
        final competition = match["competition"]?["name"] ?? "Không rõ";
        final date = match["utcDate"] ?? "";
        final formattedDate = MatchUtils.formatMatchTime(date);

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$competition • $formattedDate",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TeamInfo(
                        team: homeTeam,
                        textColor: Colors.green, // Màu cho đội nhà
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "$homeScore - $awayScore",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TeamInfo(
                        team: awayTeam,
                        textColor: Colors.blue, // Màu cho đội khách
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}