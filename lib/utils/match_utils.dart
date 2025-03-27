class MatchUtils {
  static List<dynamic> sortStandingsTable(List<dynamic> table) {
    final allSamePosition = table.every((team) => team["position"] == table[0]["position"]);
    final sortedTable = List.from(table);

    if (allSamePosition && table[0]["playedGames"] == 0) {
      sortedTable.sort((a, b) => a["team"]["name"].compareTo(b["team"]["name"]));
    }

    return sortedTable;
  }

  static bool isSeasonNotStarted(List<dynamic> table) {
    return table.isNotEmpty &&
        table.every((team) => team["position"] == table[0]["position"]) &&
        table[0]["playedGames"] == 0;
  }

  static String getTeamPosition(dynamic team) {
    return team["position"]?.toString() ?? "-";
  }

  static String formatMatchTime(String utcDate) {
    if (utcDate.isEmpty) return "Không rõ";
    final parts = utcDate.split("T");
    final date = parts[0];
    final time = parts[1].substring(0, 5);
    return "$date lúc $time";
  }
}