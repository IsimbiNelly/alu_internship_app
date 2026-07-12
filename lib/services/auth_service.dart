import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign up a new user
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    AppUser newUser = AppUser(
      uid: result.user!.uid,
      email: email,
      name: name,
      role: role,
    );

    await _db.collection('users').doc(newUser.uid).set(newUser.toMap());

    return newUser;
  }

  // Log in existing user
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    DocumentSnapshot doc =
        await _db.collection('users').doc(result.user!.uid).get();

    return AppUser.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Log out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if someone is already logged in
  User? get currentUser => _auth.currentUser;
}