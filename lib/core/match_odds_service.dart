import '../core/api_service.dart';
import '../core/odd_service.dart';

class MatchOddsService {
  final ApiService apiService = ApiService();
  final OddsService oddsService = OddsService();

  Future<Map<String, dynamic>> mapMatchOdds(Map<String, dynamic> matchData, String areaCode) async {
    try {
      final homeTeam = matchData['homeTeam']['name'] as String;
      final awayTeam = matchData['awayTeam']['name'] as String;
      final matchTime = DateTime.parse(matchData['utcDate'] as String);
      final competitionTitle = matchData['competition']['name'] as String;

      final sportKey = await oddsService.getSportKeyFromTitle(competitionTitle, areaCode);
      print("Mapped sportKey: $sportKey");

      if (sportKey == null) {
        return {
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'matchTime': matchTime.toIso8601String(),
          'competition': competitionTitle,
          'sportKey': null,
          'odds': 'No odds available - sportKey not found',
        };
      }

      final odds = await oddsService.fetchOddsForMatch(
        sportKey: sportKey,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        matchStartTime: matchTime,
        areaCode: areaCode,
      );

      return {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'matchTime': matchTime.toIso8601String(),
        'competition': competitionTitle,
        'sportKey': sportKey,
        'odds': odds ?? 'No odds available',
      };
    } catch (e) {
      print('Error mapping match odds: $e');
      return {
        'homeTeam': matchData['homeTeam']['name'],
        'awayTeam': matchData['awayTeam']['name'],
        'matchTime': DateTime.parse(matchData['utcDate']).toIso8601String(),
        'competition': matchData['competition']['name'],
        'sportKey': null,
        'odds': 'Error fetching odds: $e',
      };
    }
  }
}

extension OddsServiceExtension on OddsService {
  Future<String?> getSportKeyFromTitle(String competitionTitle, String areaCode) async {
    // Bảng ánh xạ từ competitionTitle và areaCode sang sportKey
    final mapping = {
      'Campeonato Brasileiro Série A-BRA': 'soccer_brazil_campeonato',
      'Championship-ENG': 'soccer_efl_champ',
      'Premier League-ENG': 'soccer_epl',
      'UEFA Champions League-EUR': 'soccer_uefa_champs_league',
      'European Championship-EUR': 'soccer_uefa_european_championship',
      'Ligue 1-FRA': 'soccer_france_ligue_one',
      'Bundesliga-DEU': 'soccer_germany_bundesliga',
      'Serie A-ITA': 'soccer_italy_serie_a',
      'Eredivisie-NLD': 'soccer_netherlands_eredivisie',
      'Primeira Liga-POR': 'soccer_portugal_primeira_liga',
    };

    // Tạo key để tra cứu trong bảng ánh xạ
    final key = '$competitionTitle-$areaCode';
    return mapping[key];
  }

  Future<Map<String, dynamic>?> fetchOddsForMatch({
    required String sportKey,
    required String homeTeam,
    required String awayTeam,
    required DateTime matchStartTime,
    required String areaCode,
    String oddsFormat = 'decimal',
  }) async {
    try {
      // Gọi API từ the-odds-api.com để lấy danh sách trận đấu
      final response = await _fetchOddsFromApi(sportKey, areaCode, oddsFormat);

      if (response == null || response.isEmpty) {
        return null;
      }

      // Lọc trận đấu cụ thể từ danh sách
      final matchedEvent = _findMatchInResponse(response, homeTeam, awayTeam, matchStartTime);

      return matchedEvent;
    } catch (e) {
      print('Error fetching odds from API: $e');
      return null;
    }
  }

  // Hàm giả định gọi API (cần triển khai thực tế với HTTP request)
  Future<List<dynamic>> _fetchOddsFromApi(String sportKey, String areaCode, String oddsFormat) async {
    // Ví dụ: Gọi HTTP request tới the-odds-api.com
    // https://api.the-odds-api.com/v4/sports/{sportKey}/odds/?apiKey={yourApiKey}®ions={areaCode}&markets=h2h&oddsFormat={oddsFormat}
    // Triển khai thực tế cần package như http và API key
    return []; // Thay bằng dữ liệu thực từ API
  }

  // Hàm lọc trận đấu từ danh sách
  Map<String, dynamic>? _findMatchInResponse(List<dynamic> events, String homeTeam, String awayTeam, DateTime matchStartTime) {
    const timeTolerance = Duration(minutes: 30); // Dung sai thời gian 30 phút

    for (var event in events) {
      final eventHomeTeam = event['home_team'] as String?;
      final eventAwayTeam = event['away_team'] as String?;
      final eventStartTime = DateTime.tryParse(event['commence_time'] as String? ?? '');

      if (eventHomeTeam == null || eventAwayTeam == null || eventStartTime == null) continue;

      // So sánh tên đội (không phân biệt hoa thường và bỏ khoảng trắng để tăng độ chính xác)
      final normalizedHomeTeam = homeTeam.toLowerCase().replaceAll(' ', '');
      final normalizedAwayTeam = awayTeam.toLowerCase().replaceAll(' ', '');
      final normalizedEventHome = eventHomeTeam.toLowerCase().replaceAll(' ', '');
      final normalizedEventAway = eventAwayTeam.toLowerCase().replaceAll(' ', '');

      // Kiểm tra khớp tên đội và thời gian
      if ((normalizedEventHome.contains(normalizedHomeTeam) && normalizedEventAway.contains(normalizedAwayTeam)) ||
          (normalizedEventHome.contains(normalizedAwayTeam) && normalizedEventAway.contains(normalizedHomeTeam))) {
        final timeDiff = eventStartTime.difference(matchStartTime).abs();
        if (timeDiff <= timeTolerance) {
          return event as Map<String, dynamic>;
        }
      }
    }
    return null; // Không tìm thấy trận đấu khớp
  }
}