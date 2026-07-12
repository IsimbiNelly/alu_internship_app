import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/opportunity.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final Opportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool applied = false;
  bool loading = false;
  bool checkingStatus = true;
  bool bookmarked = false;
  String? bookmarkDocId;

  @override
  void initState() {
    super.initState();
    checkIfAlreadyApplied();
    checkIfBookmarked();
  }

  Future<void> checkIfAlreadyApplied() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);

    final result = await FirebaseFirestore.instance
        .collection('applications')
        .where('opportunityId', isEqualTo: widget.opportunity.id)
        .where('studentId', isEqualTo: auth.currentUser!.uid)
        .get();

    setState(() {
      applied = result.docs.isNotEmpty;
      checkingStatus = false;
    });
  }

  Future<void> checkIfBookmarked() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);

    final result = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where('opportunityId', isEqualTo: widget.opportunity.id)
        .where('studentId', isEqualTo: auth.currentUser!.uid)
        .get();

    if (result.docs.isNotEmpty) {
      setState(() {
        bookmarked = true;
        bookmarkDocId = result.docs.first.id;
      });
    }
  }

  Future<void> toggleBookmark() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);

    if (bookmarked && bookmarkDocId != null) {
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(bookmarkDocId)
          .delete();
      setState(() {
        bookmarked = false;
        bookmarkDocId = null;
      });
    } else {
      final doc = await FirebaseFirestore.instance.collection('bookmarks').add({
        'opportunityId': widget.opportunity.id,
        'opportunityTitle': widget.opportunity.title,
        'category': widget.opportunity.category,
        'startupName': widget.opportunity.startupName,
        'studentId': auth.currentUser!.uid,
      });
      setState(() {
        bookmarked = true;
        bookmarkDocId = doc.id;
      });
    }
  }

  Future<void> apply() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('applications').add({
      'opportunityId': widget.opportunity.id,
      'opportunityTitle': widget.opportunity.title,
      'studentId': auth.currentUser!.uid,
      'studentName': auth.currentUser!.name,
      'appliedAt': Timestamp.now(),
    });

    setState(() {
      loading = false;
      applied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);
    final isStudent = auth.currentUser?.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.opportunity.title),
        actions: [
          if (isStudent)
            IconButton(
              icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
              onPressed: toggleBookmark,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.opportunity.category,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Posted by ${widget.opportunity.startupName}',
                style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            Text(widget.opportunity.description),
            const Spacer(),
            if (isStudent)
              checkingStatus
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: applied || loading ? null : apply,
                      child: loading
                          ? const CircularProgressIndicator()
                          : Text(applied ? 'Applied ✓' : 'Apply'),
                    ),
          ],
        ),
      ),
    );
  }
}