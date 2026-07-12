import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/opportunity_service.dart';
import '../models/opportunity.dart';
import 'post_opportunity_screen.dart';
import 'opportunity_detail_screen.dart';
import 'auth_screen.dart';
import 'my_applications_screen.dart';
import 'bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);
    final opportunityService = OpportunityService();
    final isStartup = auth.currentUser?.role == 'startup';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
        actions: [
          if (!isStartup)
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                );
              },
            ),
          if (!isStartup)
            IconButton(
              icon: const Icon(Icons.assignment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: isStartup
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PostOpportunityScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search opportunities...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Opportunity>>(
              stream: opportunityService.getOpportunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No opportunities yet.'));
                }

                final opportunities = snapshot.data!.where((opp) {
                  return opp.title.toLowerCase().contains(searchQuery) ||
                      opp.category.toLowerCase().contains(searchQuery) ||
                      opp.startupName.toLowerCase().contains(searchQuery);
                }).toList();

                if (opportunities.isEmpty) {
                  return const Center(child: Text('No matching opportunities.'));
                }

                return ListView.builder(
                  itemCount: opportunities.length,
                  itemBuilder: (context, index) {
                    final opp = opportunities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(opp.title),
                        subtitle: Text('${opp.category} • ${opp.startupName}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OpportunityDetailScreen(opportunity: opp),
                            ),
                          );
                        },
                      ),
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