import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider cho Supabase client
final supabaseProvider = Provider((ref) => Supabase.instance.client);

/// Provider cho current user (reactive)
final currentUserProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Provider cho auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

/// Provider kiểm tra đã login chưa
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull != null;
});

/// Auth Service Provider
final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService {
  final Ref _ref;
  
  AuthService(this._ref);
  
  SupabaseClient get _supabase => _ref.read(supabaseProvider);

  /// Đăng ký tài khoản mới
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  /// Đăng nhập
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Lấy user hiện tại
  User? get currentUser => _supabase.auth.currentUser;

  /// Lấy session hiện tại
  Session? get currentSession => _supabase.auth.currentSession;
}
