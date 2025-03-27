// lib/core/odd_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OddsService {
  static const String apiKey = '93c5fab67b840ca738faa070d70c4e4d'; // API key của bạn
  static const String baseUrl = 'api.the-odds-api.com';

  /// Lấy danh sách các môn thể thao trong mùa
  Future<List<Map<String, dynamic>>> getInSeasonSports() async {
    final url = Uri.https(baseUrl, '/v4/sports/', {'apiKey': apiKey});
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> sports = json.decode(response.body);
        return sports.where((sport) => sport['active'] == true).cast<Map<String, dynamic>>().toList();
      } else {
        throw Exception('Failed to load sports: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching sports: $e');
    }
  }

  /// Ánh xạ competitionTitle và areaCode sang sportKey
  Future<String> getSportKeyFromTitle(String competitionTitle, String areaCode) async {
    final Map<String, Map<String, String>> competitionToSportKey = {
      'BRA': {
        'Campeonato Brasileiro Série A': 'soccer_brazil_campeonato',
      },
      'ENG': {
        'Premier League': 'soccer_epl',
        'Championship': 'soccer_efl_champ',
      },
      'EUR': {
        'UEFA Champions League': 'soccer_uefa_champs_league',
        'European Championship': 'soccer_uefa_european_championship',
      },
      'FRA': {
        'Ligue 1': 'soccer_france_ligue_one',
      },
      'DEU': {
        'Bundesliga': 'soccer_germany_bundesliga',
      },
      'ITA': {
        'Serie A': 'soccer_italy_serie_a',
      },
      'NLD': {
        'Eredivisie': 'soccer_netherlands_eredivisie',
      },
      'POR': {
        'Primeira Liga': 'soccer_portugal_primeira_liga',
      },
    };

    final areaSports = competitionToSportKey[areaCode.toUpperCase()];
    if (areaSports != null && areaSports.containsKey(competitionTitle)) {
      print("✅ Mapped $competitionTitle ($areaCode) -> ${areaSports[competitionTitle]!}");
      return areaSports[competitionTitle]!;
    }

    final sports = await getInSeasonSports();
    for (var sport in sports) {
      if (sport['title'].toLowerCase() == competitionTitle.toLowerCase()) {
        print("✅ Matched from API: $competitionTitle -> ${sport['key']}");
        return sport['key'];
      }
    }

    print("⚠ Không tìm thấy sportKey cho $competitionTitle ($areaCode), sử dụng mặc định soccer_epl");
    return 'soccer_epl'; // Default nếu không tìm thấy
  }

  /// Chuyển `areaCode` sang `region`
  String mapAreaCodeToRegion(String areaCode) {
    final Map<String, String> areaToRegion = {
      'ENG': 'uk',
      'BRA': 'us',
      'ESP': 'eu',
      'DEU': 'eu',
      'FRA': 'eu',
      'ITA': 'eu',
      'NLD': 'eu',
      'POR': 'eu',
      'EUR': 'eu',
      'AUS': 'au',
    };
    return areaToRegion[areaCode.toUpperCase()] ?? 'us';
  }

  /// Lấy tỷ lệ cược cho một trận đấu từ the-odds-api.com
  Future<Map<String, dynamic>?> fetchOddsForMatch({
    required String sportKey,
    required String homeTeam,
    required String awayTeam,
    required DateTime matchStartTime,
    required String areaCode,
    String markets = 'h2h',
    String oddsFormat = 'decimal',
  }) async {
    final regions = mapAreaCodeToRegion(areaCode);
    final url = Uri.https(
      baseUrl,
      '/v4/sports/$sportKey/odds/',
      {
        'apiKey': apiKey,
        'regions': regions,
        'markets': markets,
        'oddsFormat': oddsFormat,
      },
    );

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> oddsData = json.decode(response.body);
        print("📡 Fetched ${oddsData.length} matches for sportKey: $sportKey");

        for (var match in oddsData) {
          final eventHomeTeam = match['home_team'] as String?;
          final eventAwayTeam = match['away_team'] as String?;
          final commenceTime = DateTime.tryParse(match['commence_time'] ?? '');

          if (eventHomeTeam == null || eventAwayTeam == null || commenceTime == null) continue;

          // Chuẩn hóa tên đội để tăng độ chính xác
          final normalizedHomeTeam = homeTeam.toLowerCase().replaceAll(' ', '');
          final normalizedAwayTeam = awayTeam.toLowerCase().replaceAll(' ', '');
          final normalizedEventHome = eventHomeTeam.toLowerCase().replaceAll(' ', '');
          final normalizedEventAway = eventAwayTeam.toLowerCase().replaceAll(' ', '');

          // Kiểm tra khớp tên đội (cho phép đảo ngược home/away)
          final teamsMatch = (normalizedEventHome.contains(normalizedHomeTeam) &&
              normalizedEventAway.contains(normalizedAwayTeam)) ||
              (normalizedEventHome.contains(normalizedAwayTeam) &&
                  normalizedEventAway.contains(normalizedHomeTeam));

          // Kiểm tra thời gian với dung sai ±30 phút
          final timeMatch = commenceTime.difference(matchStartTime).inMinutes.abs() < 30;

          if (teamsMatch && timeMatch) {
            print("✅ Matched match: $eventHomeTeam vs $eventAwayTeam at $commenceTime");
            return match as Map<String, dynamic>;
          }
        }
        print("⚠ No matching match found for $homeTeam vs $awayTeam at $matchStartTime");
        return null;
      } else {
        throw Exception('Failed to load odds: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching odds: $e');
    }
  }
}