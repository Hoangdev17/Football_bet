import 'package:flutter/material.dart';
import '../core/api_service.dart';

class MatchListScreen extends StatefulWidget {
  final int leagueId; // ID giải đấu được truyền vào

  MatchListScreen({required this.leagueId});

  @override
  _MatchListScreenState createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  late Future<List<dynamic>> _matches;

  @override
  void initState() {
    super.initState();
    _matches = ApiService.fetchMatches(widget.leagueId); // Gọi API để lấy danh sách trận đấu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách trận đấu"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _matches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có trận đấu nào!"));
          }

          final matches = snapshot.data!;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "${match["homeTeam"]["name"]} vs ${match["awayTeam"]["name"]}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Thời gian: ${match["utcDate"]}"),
                  trailing: Icon(Icons.sports_soccer, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
