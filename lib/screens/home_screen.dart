import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'MatchListScreen.dart'; // Import màn hình trận đấu

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _leagues;

  @override
  void initState() {
    super.initState();
    _leagues = ApiService.fetchLeagues(); // Gọi API khi khởi động màn hình
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách giải đấu"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _leagues,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có giải đấu nào!"));
          }

          final leagues = snapshot.data!.take(10).toList();

          return ListView.builder(
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              final league = leagues[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: league["emblem"] != null
                      ? Image.network(league["emblem"], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
                  title: Text(league["name"], maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text("Quốc gia: ${league["area"]["name"]}"),
                  onTap: () {
                    // Chuyển sang màn hình danh sách trận đấu
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
      ),
    );
  }
}
