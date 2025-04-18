import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/auth_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> favoriteMatches = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final favorites = await AuthService.getFavoriteMatches();
      setState(() {
        favoriteMatches = favorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi khi tải danh sách yêu thích: $e';
      });
    }
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
          onRefresh: fetchFavorites,
          color: Colors.green,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                title: const Text('Trận đấu yêu thích', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        onPressed: fetchFavorites,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
                    : favoriteMatches.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Chưa có trận đấu yêu thích nào',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
                    : Column(
                  children: favoriteMatches.map((match) {
                    return FavoriteMatchCard(match: match);
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

class FavoriteMatchCard extends StatelessWidget {
  final dynamic match;

  const FavoriteMatchCard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeTeam = match['homeTeam'];
    final awayTeam = match['awayTeam'];
    final matchTime = DateTime.parse(match['matchDate']);

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
                ],
              ),
            ),
            const Icon(Icons.sports_soccer, color: Colors.green, size: 30),
          ],
        ),
      ),
    );
  }
}