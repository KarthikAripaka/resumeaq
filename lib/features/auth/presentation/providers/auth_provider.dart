import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() {
    _watchAuthState();
    return Supabase.instance.client.auth.currentUser;
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      return null; // OAuth will update auth state via listener
    });
  }

  // Future<void> signInAnonymously() async {
  //   state = const AsyncValue.loading();
  //   state = await AsyncValue.guard(() async {
  //     final response = await Supabase.instance.client.auth.signInAnonymously();
  //     return response.user;
  //   });
  // }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signOut();
      return null;
    });
  }

  void _watchAuthState() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      state = AsyncValue.data(event.session?.user);
    });
  }
}