import 'package:intl/intl.dart';

class LiveMatch {
  final int fixtureId;
  final String leagueName;
  final String leagueLogo;
  final String homeTeam;
  final String homeLogo;
  final String awayTeam;
  final String awayLogo;
  final int homeGoals;
  final int awayGoals;
  final String status;
  final int? elapsedTime;
  final DateTime matchDate;
  final List<MatchEvent> events;

  LiveMatch({
    required this.fixtureId,
    required this.leagueName,
    required this.leagueLogo,
    required this.homeTeam,
    required this.homeLogo,
    required this.awayTeam,
    required this.awayLogo,
    required this.homeGoals,
    required this.awayGoals,
    required this.status,
    required this.matchDate,
    this.elapsedTime,
    this.events = const [],
  });

  factory LiveMatch.fromJson(Map<String, dynamic> json) {
    final fixture = json["fixture"];
    final league = json["league"];
    final teams = json["teams"];
    final goals = json["goals"];

    return LiveMatch(
      fixtureId: fixture["id"],
      leagueName: league["name"],
      leagueLogo: league["logo"],
      homeTeam: teams["home"]["name"],
      homeLogo: teams["home"]["logo"],
      awayTeam: teams["away"]["name"],
      awayLogo: teams["away"]["logo"],
      homeGoals: goals["home"] ?? 0,
      awayGoals: goals["away"] ?? 0,
      status: fixture["status"]["short"],
      elapsedTime: fixture["status"]["elapsed"],
      matchDate: DateTime.parse(fixture["date"]),
    );
  }

  LiveMatch copyWith({
    List<MatchEvent>? events,
    int? homeGoals,
    int? awayGoals,
    String? status,
    int? elapsedTime,
  }) {
    return LiveMatch(
      fixtureId: fixtureId,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      homeTeam: homeTeam,
      homeLogo: homeLogo,
      awayTeam: awayTeam,
      awayLogo: awayLogo,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      status: status ?? this.status,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      matchDate: matchDate,
      events: events ?? this.events,
    );
  }

  String get matchTime => DateFormat('HH:mm').format(matchDate);

  bool get isUpcoming => status == "NS";
  bool get isLive => !isUpcoming && status != "FT" && status != "POSTPONED";
  bool get isFinished => status == "FT";
}

class MatchEvent {
  final String time;
  final String type;
  final String detail;
  final String playerName;
  final String teamName;
  final String? assistName;
  final String? playerPhoto;

  MatchEvent({
    required this.time,
    required this.type,
    required this.detail,
    required this.playerName,
    required this.teamName,
    this.assistName,
    this.playerPhoto,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      time: "${json["time"]["elapsed"]}'",
      type: json["type"],
      detail: json["detail"],
      playerName: json["player"]["name"] ?? "",
      teamName: json["team"]["name"],
      assistName: json["assist"]?["name"],
      playerPhoto: json["player"]["photo"],
    );
  }

  String get eventIcon {
    switch (type) {
      case "Goal":
        return "⚽";
      case "Card":
        return detail == "Yellow Card" ? "🟨" : "🟥";
      case "subst":
        return "🔄";
      case "Var":
        return "📺";
      default:
        return "🔹";
    }
  }

  String get eventDescription {
    switch (type) {
      case "Goal":
        return "Ghi bàn";
      case "Card":
        return detail == "Yellow Card" ? "Thẻ vàng" : "Thẻ đỏ";
      case "subst":
        return "Thay người";
      case "Var":
        return "VAR";
      default:
        return type;
    }
  }
}