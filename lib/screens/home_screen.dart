import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'MatchListScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _leagues;

  @override
  void initState() {
    super.initState();
    _leagues = ApiService.fetchLeagues();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _leagues,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có giải đấu nào!"));
        }

        final leagues = snapshot.data!.take(10).toList();

        return ListView.builder(
          itemCount: leagues.length,
          itemBuilder: (context, index) {
            final league = leagues[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: league["emblem"] != null
                    ? Image.network(league["emblem"], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
                title: Text(league["name"], maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text("Quốc gia: ${league["area"]["name"]}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchListScreen(leagueId: league["id"]),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    HomeScreen(), // Tab All Games
    const Center(child: Text("Live Matches")), // Tab Live
    const Center(child: Text("Betting Tips")), // Tab Tips
    const Center(child: Text("Favorite Matches")), // Tab Favorites
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "All Games"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Live"),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: "Tips"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "All Games";
      case 1:
        return "Live Matches";
      case 2:
        return "Betting Tips";
      case 3:
        return "Favorites";
      default:
        return "Football Bet";
    }
  }
}
