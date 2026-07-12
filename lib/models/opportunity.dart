import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String category; // e.g. "Development", "Design", "Marketing"
  final String startupId;
  final String startupName;
  final Timestamp createdAt;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startupId,
    required this.startupName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'startupId': startupId,
      'startupName': startupName,
      'createdAt': createdAt,
    };
  }

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) {
    return Opportunity(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}