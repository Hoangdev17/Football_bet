import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<dynamic> upcomingMatches = [];
  bool isLoading = false;
  String errorMessage = '';
  List<String> favoriteIds = [];

  final List<int> majorLeagueIds = [
    2021, // Premier League
    2014, // La Liga
    2002, // Bundesliga
    2015, // Ligue 1
    2019, // Serie A
  ];

  @override
  void initState() {
    super.initState();
    fetchTips();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds = prefs.getStringList('favorite_matches') ?? [];
    });
  }

  Future<void> fetchTips() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      List<dynamic> allMatches = [];
      for (int leagueId in majorLeagueIds) {
        final matches = await ApiService.fetchMatches(leagueId);
        allMatches.addAll(matches);
        await Future.delayed(const Duration(milliseconds: 500)); // Delay tránh 429
      }

      final now = DateTime.now();
      final twoDaysFromNow = now.add(const Duration(days: 2));
      final upcoming = allMatches.where((match) {
        final matchDate = DateTime.parse(match['utcDate']);
        final status = match['status'];
        // Lọc các trận SCHEDULED trong 2 ngày tới
        return status == 'SCHEDULED' &&
            matchDate.isAfter(now) &&
            matchDate.isBefore(twoDaysFromNow);
      }).toList();

      setState(() {
        upcomingMatches = upcoming;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().contains('429')
            ? 'Vượt quá giới hạn API. Vui lòng thử lại sau vài phút.'
            : 'Lỗi khi tải dữ liệu: $e';
      });
    }
  }

  Future<void> toggleFavorite(int matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_matches') ?? [];
    final idString = matchId.toString();

    if (favoriteIds.contains(idString)) {
      favoriteIds.remove(idString);
    } else {
      favoriteIds.add(idString);
    }
    await prefs.setStringList('favorite_matches', favoriteIds);
    setState(() {
      this.favoriteIds = favoriteIds;
    });
  }

  String _generateTip(dynamic match) {
    final homeTeam = match['homeTeam']['name'];
    return 'Đặt cược $homeTeam thắng (Tỷ lệ giả định: 1.8)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey[900]!],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchTips,
          color: Colors.green,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                title: const Text('Betting Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                floating: true,
                automaticallyImplyLeading: false,
              ),
              SliverToBoxAdapter(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.green))
                    : errorMessage.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchTips,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
                    : upcomingMatches.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Không có trận đấu sắp diễn ra trong 2 ngày tới',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
                    : Column(
                  children: upcomingMatches.map((match) {
                    return TipCard(
                      match: match,
                      tip: _generateTip(match),
                      isFavorite: favoriteIds.contains(match['id'].toString()),
                      onToggleFavorite: () => toggleFavorite(match['id']),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final dynamic match;
  final String tip;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const TipCard({
    Key? key,
    required this.match,
    required this.tip,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeTeam = match['homeTeam']['name'];
    final awayTeam = match['awayTeam']['name'];
    final matchTime = DateTime.parse(match['utcDate']);

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$homeTeam vs $awayTeam',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thời gian: ${DateFormat('HH:mm - dd/MM').format(matchTime.toLocal())}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mẹo: $tip',
                    style: const TextStyle(fontSize: 14, color: Colors.greenAccent),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.sports_soccer, color: Colors.green, size: 30),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 30,
                  ),
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}