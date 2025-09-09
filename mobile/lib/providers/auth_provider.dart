import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final String? pendingId;
  final bool isAuthenticated;
  final bool isNewUser;

  AuthState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.pendingId,
    this.isAuthenticated = false,
    this.isNewUser = false,
  });

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
    String? pendingId,
    bool? isAuthenticated,
    bool? isNewUser,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      pendingId: pendingId ?? this.pendingId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthState _state = AuthState();

  AuthState get state => _state;

  AuthProvider() {
    _loadSavedAuth();
  }

  Future<void> _loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (accessToken != null && refreshToken != null) {
      _state = _state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        isAuthenticated: true,
      );
      notifyListeners();
    }
  }

  Future<void> startAuth(String contact) async {
    final result = await _authService.startAuth(contact);
    if (result.error == null && result.pendingId != null) {
      _state = _state.copyWith(pendingId: result.pendingId);
      notifyListeners();
    } else {
      throw Exception(result.error ?? 'Failed to start authentication');
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_state.pendingId == null) {
      throw Exception('No pending authentication');
    }

    final result = await _authService.verifyOtp(_state.pendingId!, otp);
    if (result.error == null && result.accessToken != null) {
      _state = _state.copyWith(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user,
        isAuthenticated: true,
        isNewUser: result.isNew,
        pendingId: null,
      );
      notifyListeners();
    } else {
      throw Exception(result.error ?? 'Failed to verify OTP');
    }
  }

  Future<void> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result.error == null && result.pendingId != null) {
      _state = _state.copyWith(pendingId: result.pendingId);
      notifyListeners();
    } else {
      throw Exception(result.error ?? 'Failed to sign in with Google');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _state = AuthState();
    notifyListeners();
  }
}
