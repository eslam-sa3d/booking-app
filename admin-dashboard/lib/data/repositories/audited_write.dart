import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared helper for repositories whose writes must be traceable in
/// auditLog. Staff/admin creates+updates go straight to Firestore but must
/// tag `updatedBy` — firestore.rules requires it to equal the caller's own
/// uid, and the matching Cloud Functions trigger (see
/// backend/functions/src/audit/triggers.ts) reads it as the audit entry's
/// actor. Deletes carry no document payload to tag, so they route through
/// the `adminDelete` callable instead, which logs them with a verified
/// actor from its own auth context.
mixin AuditedWrite {
  FirebaseAuth get auth;
  FirebaseFunctions get functions;

  String get currentUid => auth.currentUser!.uid;

  Map<String, dynamic> tagged(Map<String, dynamic> data) => {...data, 'updatedBy': currentUid};

  Future<void> auditedDelete(String collection, String docId) {
    return functions.httpsCallable('adminDelete').call({'collection': collection, 'docId': docId});
  }
}
