import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_connect/feed_screen.dart';
import 'package:social_connect/profile_screen.dart';
import 'package:social_connect/chat_list_screen.dart';
import 'package:social_connect/notifications_screen.dart';
import 'package:social_connect/search_screen.dart';
import 'package:social_connect/theme.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  static final List<Widget> _pages = <Widget>[
    const FeedScreen(),
    const SearchScreen(),
    const ChatListScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), // Messages Icon
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(), // Use helper
            label: 'Activity',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientUid', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final bool hasUnread =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications),
            if (hasUnread)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
