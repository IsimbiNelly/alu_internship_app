import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/opportunity_service.dart';
import '../models/opportunity.dart';
import '../main.dart';

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

  final categoryColors = {
    'Development': const Color(0xFF6C4AB6),
    'Design': const Color(0xFFFF7A59),
    'Marketing': const Color(0xFF2ED9C3),
    'Business': const Color(0xFFFFC93C),
    'Content': const Color(0xFFFF6B9D),
  };

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

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
      appBar: AppBar(title: const Text('✨ Post an Opportunity')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Title',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'e.g. Social Media Assistant',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the role and responsibilities...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 18),
            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final selected = category == c;
                final color = categoryColors[c]!;
                return GestureDetector(
                  onTap: () => setState(() => category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        color: selected ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            isPosting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: submit,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Post Opportunity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}