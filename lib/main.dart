import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/MatchListScreen.dart'; // Import màn hình danh sách trận đấu
import 'screens/MatchInforScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Bet',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
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
  Widget _currentScreen = HomeScreen(); // Mặc định là HomeScreen

  final List<Widget> _tabs = [
    HomeScreen(),
    Text("Live"),
    Text("Tips"),
    Text("Favorites"),
    Text("Leagues"),
  ];

  // Mở màn hình danh sách trận đấu
  void _openMatchListScreen(int leagueId) {
    setState(() {
      _currentScreen = MatchListScreen(leagueId: leagueId);
    });
  }

  // Quay về trang Home
  void _goBackToHome() {
    setState(() {
      _currentScreen = HomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        leading: _currentScreen is MatchListScreen
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _goBackToHome, // Quay lại Home khi nhấn Back
        )
            : null,
      ),
      body: _currentScreen, // Hiển thị màn hình hiện tại
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "All Games",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: "Live",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: "Tips",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Leagues",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _currentScreen = _tabs[index]; // Chuyển đổi giữa các tab
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
        return "Live";
      case 2:
        return "Tips";
      case 3:
        return "Favorites";
      case 4:
        return "Leagues";
      default:
        return "Football Bet";
    }
  }
}
