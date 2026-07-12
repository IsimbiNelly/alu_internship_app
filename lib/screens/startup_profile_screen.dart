import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart' as app_auth;

class StartupProfileScreen extends StatefulWidget {
  const StartupProfileScreen({super.key});

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  final descController = TextEditingController();
  final industryController = TextEditingController();
  bool isVerified = false;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get();

    final data = doc.data();
    if (data != null) {
      descController.text = data['bio'] ?? '';
      industryController.text = data['industry'] ?? '';
      isVerified = data['isVerified'] ?? false;
    }

    setState(() => loading = false);
  }

  Future<void> saveProfile() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    setState(() => saving = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
      'bio': descController.text.trim(),
      'industry': industryController.text.trim(),
    });

    setState(() => saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Startup Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(auth.currentUser!.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (isVerified)
                  const Icon(Icons.verified, color: Colors.blue, size: 20)
                else
                  const Chip(label: Text('Not Verified')),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: industryController,
              decoration: const InputDecoration(
                labelText: 'Industry (e.g. Fintech, EdTech)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'About your startup',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text('Save Profile'),
                  ),
          ],
        ),
      ),
    );
  }
}