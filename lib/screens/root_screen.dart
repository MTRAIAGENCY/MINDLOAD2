import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/main_bottom_nav.dart';
import 'home_screen.dart';
import 'ai_chat_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(key: _homeKey),
          const AiChatScreen(),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _index,
        onTabSelected: (i) => setState(() => _index = i),
        onAddPressed: () => _homeKey.currentState?.openAddSheet(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: FloatingActionButton(
          onPressed: () => _homeKey.currentState?.openAddSheet(),
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
    );
  }
}
