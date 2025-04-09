import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> favoriteMatches = [];
  bool isLoading = false;
  String errorMessage = '';

  // Danh sách ID của các giải đấu lớn
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
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorite_matches') ?? [];
      if (favoriteIds.isEmpty) {
        setState(() {
          favoriteMatches = [];
          isLoading = false;
        });
        return;
      }

      List<dynamic> allMatches = [];
      for (int leagueId in majorLeagueIds) {
        final matches = await ApiService.fetchMatches(leagueId);
        allMatches.addAll(matches);
        await Future.delayed(const Duration(milliseconds: 500)); // Delay để tránh 429
      }

      final favorites = allMatches.where((match) => favoriteIds.contains(match['id'].toString())).toList();

      setState(() {
        favoriteMatches = favorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().contains('429')
            ? 'Vượt quá giới hạn API. Vui lòng thử lại sau.'
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
    await loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadFavorites,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadFavorites,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        )
            : favoriteMatches.isEmpty
            ? const Center(child: Text('Chưa có trận đấu yêu thích nào'))
            : ListView.builder(
          itemCount: favoriteMatches.length,
          itemBuilder: (context, index) {
            final match = favoriteMatches[index];
            return FavoriteCard(
              match: match,
              onToggleFavorite: () => toggleFavorite(match['id']),
            );
          },
        ),
      ),
    );
  }
}

class FavoriteCard extends StatelessWidget {
  final dynamic match;
  final VoidCallback onToggleFavorite;

  const FavoriteCard({Key? key, required this.match, required this.onToggleFavorite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeTeam = match['homeTeam']['name'];
    final awayTeam = match['awayTeam']['name'];
    final matchTime = DateTime.parse(match['utcDate']);
    final status = match['status'];

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$homeTeam vs $awayTeam',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('HH:mm').format(matchTime.toLocal())} - $status',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: onToggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}