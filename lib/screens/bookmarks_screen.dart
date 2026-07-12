import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart' as app_auth;

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookmarks')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookmarks')
            .where('studentId', isEqualTo: auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookmarks yet.'));
          }

          final bookmarks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final data = bookmarks[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.orange),
                  title: Text(data['opportunityTitle'] ?? ''),
                  subtitle: Text(
                      '${data['category'] ?? ''} • ${data['startupName'] ?? ''}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}