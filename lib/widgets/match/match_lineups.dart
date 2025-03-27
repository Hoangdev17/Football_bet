import 'package:flutter/material.dart';
import '../shared/team_info.dart';
import '../shared/player_tile.dart';
import '../../utils/match_utils.dart';

class MatchLineups extends StatelessWidget {
  final Future<Map<String, dynamic>> homeTeamDetail;
  final Future<Map<String, dynamic>> awayTeamDetail;
  final int? homeTeamId;
  final int? awayTeamId;

  const MatchLineups({
    required this.homeTeamDetail,
    required this.awayTeamDetail,
    this.homeTeamId,
    this.awayTeamId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([homeTeamDetail, awayTeamDetail]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return const Center(child: Text('Không có dữ liệu đội hình'));
        }

        return _buildLineupsContent(snapshot.data!);
      },
    );
  }

  Widget _buildLineupsContent(List<dynamic> data) {
    final homeTeamData = data[0] as Map<String, dynamic>;
    final awayTeamData = data[1] as Map<String, dynamic>;

    if (homeTeamId == awayTeamId) {
      return const Center(child: Text("Lỗi: Hai đội trùng ID"));
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Đội nhà"),
              Tab(text: "Đội khách"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTeamDetailView(homeTeamData),
                _buildTeamDetailView(awayTeamData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamDetailView(Map<String, dynamic> teamData) {
    final name = teamData["name"] ?? "Không rõ";
    final shortName = teamData["shortName"] ?? "N/A";
    final crest = teamData["crest"] ?? "";
    final venue = teamData["venue"] ?? "Không rõ";
    final founded = teamData["founded"]?.toString() ?? "N/A";
    final squad = teamData["squad"] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            if (crest.isNotEmpty)
              Image.network(
                crest,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 50),
              ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Tên ngắn: $shortName"),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("Sân nhà: $venue", style: const TextStyle(fontSize: 16)),
        Text("Thành lập: $founded", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        const Text(
          "Đội hình chính thức",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (squad.isEmpty)
          const Text("Không có thông tin đội hình")
        else
          ...squad.map((player) => PlayerTile(player: player)).toList(),
      ],
    );
  }
}