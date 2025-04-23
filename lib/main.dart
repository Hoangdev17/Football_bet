import 'package:ffff/screens/User_Screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/live_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Football Bet',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Widget _currentScreen;

  final List<Widget> _tabs = [
    HomeScreen(),
    LiveMatchesScreen(),
    UserScreen(),
    TipsScreen(),
    FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentScreen = _tabs[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: _currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
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
              icon: Icon(Icons.login_rounded),
              label: "User"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: "Tips",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Favorites",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _currentScreen = _tabs[index];
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
        return "User";
      case 3:
        return "Tips";
      case 4:
        return "Favorites";
      default:
        return "Football Bet";
    }
  }
}