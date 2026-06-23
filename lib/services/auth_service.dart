import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'cloud_sync_service.dart';

class AuthService {
  AuthService(this._auth, this._googleSignIn, this._syncService);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final CloudSyncService _syncService;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (kIsWeb) return;
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _syncService.bootstrapUser(credential.user);
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (kIsWeb) return;
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();
    await _syncService.bootstrapUser(credential.user);
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) return;
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    await _syncService.bootstrapUser(result.user);
  }

  Future<void> signOut() async {
    if (kIsWeb) return;
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

final authService = AuthService(
  FirebaseAuth.instance,
  GoogleSignIn(scopes: const ['email']),
  cloudSyncService,
);
