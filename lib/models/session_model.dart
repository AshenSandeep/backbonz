import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String? id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;

  const SessionModel({
    this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  // Convert to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationSeconds': duration.inSeconds,
    };
  }

  // Create a SessionModel from a Firestore document
  factory SessionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      userId: data['userId'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      duration: Duration(seconds: data['durationSeconds'] as int),
    );
  }
}