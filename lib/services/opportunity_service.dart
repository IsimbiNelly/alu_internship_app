import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityService {
  final CollectionReference _opportunities =
      FirebaseFirestore.instance.collection('opportunities');

  // Get a live stream of all opportunities (auto-updates in real time!)
  Stream<List<Opportunity>> getOpportunities() {
    return _opportunities
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Opportunity.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Post a new opportunity
  Future<void> postOpportunity(Opportunity opportunity) async {
    await _opportunities.add(opportunity.toMap());
  }
}