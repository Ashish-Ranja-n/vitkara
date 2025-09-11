import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final String? pendingId;
  final bool isAuthenticated;
  final bool isNewUser;
  final bool isLoading;

  AuthState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.pendingId,
    this.isAuthenticated = false,
    this.isNewUser = false,
    this.isLoading = true,
  });

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
    String? pendingId,
    bool? isAuthenticated,
    bool? isNewUser,
    bool? isLoading,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      pendingId: pendingId ?? this.pendingId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isNewUser: isNewUser ?? this.isNewUser,
      isLoading: isLoading ?? this.isLoading,
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
    final userString = prefs.getString('user');
    final flowCompleted = prefs.getBool('flow_completed') ?? false;

    if (accessToken != null) {
      Map<String, dynamic>? user;
      if (userString != null) {
        try {
          user = json.decode(userString);
        } catch (e) {
          // If parsing fails, user will be null
        }
      }

      _state = _state.copyWith(
        accessToken: accessToken,
        refreshToken: accessToken, // Use same token for both
        user: user,
        isAuthenticated: true,
        isNewUser: !flowCompleted, // If flow is completed, user is not new
        isLoading: false,
      );
    } else {
      _state = _state.copyWith(isLoading: false);
    }
    notifyListeners();
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

  void updateAuthState({
    required bool isAuthenticated,
    required bool isNewUser,
    String? token,
    Map<String, dynamic>? user,
  }) {
    _state = _state.copyWith(
      accessToken: token,
      user: user,
      isAuthenticated: isAuthenticated,
      isNewUser: isNewUser,
    );
    notifyListeners();
  }

  void markFlowCompleted() {
    _state = _state.copyWith(isNewUser: false);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result.error == null && result.accessToken != null) {
      _state = _state.copyWith(
        accessToken: result.accessToken,
        user: result.user,
        isAuthenticated: true,
        isNewUser: result.isNew,
      );
      notifyListeners();
    } else {
      throw Exception(result.error ?? 'Failed to sign in with Google');
    }
  }

  Future<bool> signOut() async {
    final success = await _authService.signOut();
    _state = AuthState(isLoading: false);
    notifyListeners();
    return success;
  }
}
