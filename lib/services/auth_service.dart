import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user session
  Session? get currentSession => _supabase.auth.currentSession;
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign in with Email and Password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Check if user is logged in
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  // Stream of auth changes (useful for auto-redirects)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
