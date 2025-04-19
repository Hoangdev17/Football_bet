import 'package:flutter/material.dart';
import 'package:football_bet/screens/RegisterScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/MatchListScreen.dart';
import 'screens/MatchInforScreen.dart';
import 'screens/Live_Screen.dart';
import 'screens/Tips_Screen.dart';
import 'screens/Favorites_Screen.dart';
import 'screens/loginscreen.dart';
import 'core/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: FutureBuilder<String?>(
        future: AuthService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return const MainScreen();
          }
          return const RegisterScreen();
        },
      ),
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
  Widget _currentScreen = HomeScreen(); // Changed to HomeScreen()

  final List<Widget> _tabs = [
    HomeScreen(), // Changed to HomeScreen()
    const LiveMatchesScreen(), // Changed to LiveMatchesScreen()
    const TipsScreen(), // Kept const, as TipsScreen has const constructor
    const FavoritesScreen(), // Changed to FavoritesScreen()
  ];

  // Mở màn hình danh sách trận đấu
  void _openMatchListScreen(int leagueId) {
    setState(() {
      _currentScreen = MatchListScreen(leagueId: leagueId);
    });
  }

  // Quay về trang Home
  void _goBackToHome() {
    setState() {
      _currentScreen = HomeScreen(); // Changed to HomeScreen()
    };
  }

  // Đăng xuất
  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        leading: _currentScreen is MatchListScreen
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToHome, // Quay lại Home khi nhấn Back
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
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
            icon: Icon(Icons.favorite),
            label: "Favorites",
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
      default:
        return "Football Bet";
    }
  }
}