import 'package:flutter/material.dart';
import 'home_page.dart';
import 'vtry_page.dart';
import 'history_page.dart';
import 'saved_page.dart';
import 'favorite_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 1; 

  // ये नाम वही होने चाहिए जो आपकी फाइलों के अंदर 'class' के नाम हैं
  final List<Widget> _pages = [
    const UserHomePage(), 
    const VTryPage(),
    const HistoryPage(),
    const SavedPage(),
    const FavoritePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: "V-Try"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Likes"),
        ],
      ),
    );
  }
}