import 'package:flutter/material.dart';
import 'package:ai_canaan_church/screens/home_screen.dart';
import 'package:ai_canaan_church/screens/saved_sermons_list_screen.dart';
import 'package:ai_canaan_church/screens/prayer_requests_screen.dart';
import 'package:ai_canaan_church/screens/more_screen.dart';
import 'package:ai_canaan_church/widgets/bottom_nav_bar.dart';
import 'package:ai_canaan_church/screens/bible_reading_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const SavedSermonsListScreen(),
      const BibleReadingScreen(),
      const PrayerRequestsScreen(),
      const MoreScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
