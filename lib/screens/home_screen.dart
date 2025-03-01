import 'package:flutter/material.dart';
import '../core/api_service.dart';

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
            return Center(child: CircularProgressIndicator()); // Hiển thị loading
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}")); // Hiển thị lỗi nếu có
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có giải đấu nào!")); // Nếu không có dữ liệu
          }

          // Hiển thị danh sách giải đấu
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final league = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: league["emblem"] != null
                      ? Image.network(league["emblem"], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
                  title: Text(league["name"], maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text("Quốc gia: ${league["area"]["name"]}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
