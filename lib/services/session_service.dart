import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

// Handles all Firestore operations for wear sessions.
class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sessions';

  // Save a completed session
  Future<void> saveSession(SessionModel session) async {
    await _firestore.collection(_collection).add(session.toMap());
  }

  // Stream today's sessions for a specific user
  Stream<List<SessionModel>> getTodaysSessions(String userId) {
    final startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SessionModel.fromDocument(doc))
        .toList());
  }
}