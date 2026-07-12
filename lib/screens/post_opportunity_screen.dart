import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/opportunity_service.dart';
import '../models/opportunity.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String category = 'Development';
  bool isPosting = false;

  final categories = [
    'Development',
    'Design',
    'Marketing',
    'Business',
    'Content'
  ];

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() => isPosting = true);

    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final service = OpportunityService();

    final opportunity = Opportunity(
      id: '',
      title: titleController.text.trim(),
      description: descController.text.trim(),
      category: category,
      startupId: auth.currentUser!.uid,
      startupName: auth.currentUser!.name,
      createdAt: Timestamp.now(),
    );

    await service.postOpportunity(opportunity);

    setState(() => isPosting = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Opportunity')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
            ),
            const SizedBox(height: 20),
            isPosting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: submit,
                    child: const Text('Post'),
                  ),
          ],
        ),
      ),
    );
  }
}