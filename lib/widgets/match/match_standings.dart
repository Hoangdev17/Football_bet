import 'package:flutter/material.dart';
import '../../utils/match_utils.dart';
import '../../utils/tab_utils.dart';
import '../shared/team_info.dart';

class MatchStandings extends StatelessWidget {
  final Future<Map<String, dynamic>> standingsFuture;
  final int? homeTeamId;
  final int? awayTeamId;

  const MatchStandings({
    required this.standingsFuture,
    this.homeTeamId,
    this.awayTeamId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabUtils.buildTabContent(
      future: standingsFuture,
      builder: (data) => _buildStandings(data),
      emptyMessage: "Không có dữ liệu bảng xếp hạng",
      errorMessage: "Lỗi khi tải dữ liệu xếp hạng",
    );
  }

  Widget _buildStandings(Map<String, dynamic> data) {
    final standings = data["standings"] as List<dynamic>?;
    if (standings == null || standings.isEmpty) {
      return const Center(child: Text("Không có dữ liệu xếp hạng"));
    }

    final table = standings[0]["table"] as List<dynamic>? ?? [];
    final sortedTable = MatchUtils.sortStandingsTable(table);

    return Column(
      children: [
        if (MatchUtils.isSeasonNotStarted(table))
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Mùa giải chưa bắt đầu, các đội được sắp xếp theo tên",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: sortedTable.length,
            itemBuilder: (context, index) => _buildTeamRow(sortedTable[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamRow(dynamic team) {
    final teamId = team["team"]["id"];
    final isHomeTeam = teamId == homeTeamId;
    final isAwayTeam = teamId == awayTeamId;
    final textColor = isHomeTeam
        ? Colors.green
        : isAwayTeam
        ? Colors.blue
        : Colors.white;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          child: Text(
            "${MatchUtils.getTeamPosition(team)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Image.network(
              team["team"]["crest"],
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                team["team"]["name"],
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${team["points"]} điểm",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${team["playedGames"]} trận",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}