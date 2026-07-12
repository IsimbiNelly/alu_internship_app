import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/opportunity.dart';
import '../main.dart';

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

  final categoryColors = {
    'Development': const Color(0xFF6C4AB6),
    'Design': const Color(0xFFFF7A59),
    'Marketing': const Color(0xFF2ED9C3),
    'Business': const Color(0xFFFFC93C),
    'Content': const Color(0xFFFF6B9D),
  };

  Color get color => categoryColors[widget.opportunity.category] ?? AppColors.primary;

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            actions: [
              if (isStudent)
                IconButton(
                  icon: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  onPressed: toggleBookmark,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 50),
              title: Text(
                widget.opportunity.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.work_outline, color: Colors.white24, size: 72),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.opportunity.category,
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Posted by ${widget.opportunity.startupName}',
                        style: const TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.opportunity.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  if (isStudent)
                    checkingStatus
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: applied || loading ? null : apply,
                              icon: loading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Icon(applied
                                      ? Icons.check_circle
                                      : Icons.send),
                              label: Text(applied ? 'Applied' : 'Apply Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    applied ? Colors.green : AppColors.secondary,
                              ),
                            ),
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}