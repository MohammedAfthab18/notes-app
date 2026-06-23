import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';

final firebaseEnabledProvider = Provider<bool>((ref) => !kIsWeb);

final authStateProvider = StreamProvider<User?>((ref) {
  if (kIsWeb) return const Stream<User?>.empty();
  return FirebaseAuth.instance.authStateChanges();
});

final authServiceProvider = Provider((ref) => authService);
