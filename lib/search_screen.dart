import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//rimport 'package:social_connect/theme.dart';
import 'package:social_connect/user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';

  // --- FIX: Removed 'late final' and gave a default value ---
  Stream<QuerySnapshot> _usersStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    // No longer need to initialize here
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      // Update the stream to search for users
      if (_searchQuery.isNotEmpty) {
        _usersStream = FirebaseFirestore.instance
            .collection('users')
            // This query finds names that start with the search query
            .where('name', isGreaterThanOrEqualTo: _searchQuery)
            .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
            .snapshots();
      } else {
        // If query is empty, reset to an empty stream
        _usersStream = const Stream.empty();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search for a user...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (_searchQuery.isEmpty) {
                  return const Center(child: Text('Type a name to search.'));
                }
                // --- ADDED: Check for errors (like missing index) ---
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error: ${snapshot.error}\n\nYou probably need to create a Firestore index for the "users" collection.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final user = doc.data() as Map<String, dynamic>;
                    final String profilePic = user['profilePictureUrl'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic)
                            : null,
                        child: profilePic.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user['name'] ?? 'No Name'),
                      subtitle: Text(
                        user['bio'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // Navigate to their profile
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(userId: user['uid']),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
