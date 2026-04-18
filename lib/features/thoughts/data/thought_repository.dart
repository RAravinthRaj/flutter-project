import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/thought.dart';
import '../../../services/ai_classifier_service.dart';

class ThoughtRepository {
  ThoughtRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AiClassifierService? classifierService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _classifierService = classifierService ?? AiClassifierService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AiClassifierService _classifierService;

  CollectionReference<Map<String, dynamic>> _thoughtsRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.thoughtsCollection);
  }

  Stream<List<Thought>> watchThoughts() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(const []);
    }

    return _thoughtsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Thought.fromFirestore).toList());
  }

  Future<void> addThought(String rawText) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('No authenticated user found.');
    }

    // SPEED FIX: Use local classification immediately instead of waiting for Cloud Functions
    final classification = _classifierService.classifyLocalSync(rawText);

    await _thoughtsRef(userId).add({
      'rawText': rawText,
      'createdAt': FieldValue.serverTimestamp(),
      'tasks': classification.tasks,
      'ideas': classification.ideas,
      'worries': classification.worries,
      'isProcessedByAi': false, // Can be updated by a background trigger later
    });
  }

  Future<void> deleteThought(String thoughtId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('No authenticated user found.');
    }
    await _thoughtsRef(userId).doc(thoughtId).delete();
  }

  Future<void> clearAllThoughts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('No authenticated user found.');
    }
    final snapshot = await _thoughtsRef(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> refresh() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _thoughtsRef(userId).limit(1).get(const GetOptions(source: Source.server));
  }
}
