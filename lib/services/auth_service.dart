import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventora_planner/services/firebase_bootstrap.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static Future<UserCredential> signInWithGoogle() async {
    await _ensureFirebaseInitialized();

    final googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw const FormatException('Google sign-in was cancelled.');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw const FormatException('Google sign-in failed: missing ID token.');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw const FormatException('Google sign-in failed: no user returned.');
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastLoginAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return userCredential;
  }

  static Future<void> signOut() async {
    await _ensureFirebaseInitialized();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> _ensureFirebaseInitialized() async {
    final ready = await FirebaseBootstrap.ensureInitialized();
    if (!ready) {
      throw const FormatException(
        'Firebase is not configured on this platform/device yet.',
      );
    }
  }
}
