import 'package:football_bet/core/odd_service.dart';

void main() async {
  final oddsService = OddsService();
  try {
    final sports = await oddsService.getInSeasonSports();
    print('Available sport keys:');
    for (var sport in sports) {
      print('Key: ${sport['key']}, Title: ${sport['title']}');
    }
  } catch (e) {
    print('Error fetching sports: $e');
  }
}