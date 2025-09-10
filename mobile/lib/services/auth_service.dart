import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final bool isNew;
  final String? pendingId;
  final String? error;

  AuthResult({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.isNew = false,
    this.pendingId,
    this.error,
  });
}

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://vitkara.com/api',
  );
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '425965460296-bkm1bphn5di9nng1fudagu9madge6k40.apps.googleusercontent.com',
  );

  // Store tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Start OTP flow
  Future<AuthResult> startAuth(String contact) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'contact': contact}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResult(pendingId: data['pendingId']);
      } else {
        String errorMessage = 'Failed to start authentication';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            // Ignore if parsing fails, use default message
          }
        }
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      return AuthResult(error: e.toString());
    }
  }

  // Verify OTP
  Future<AuthResult> verifyOtp(String pendingId, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pendingId': pendingId, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(data['accessToken'], data['refreshToken']);

        return AuthResult(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          user: data['user'],
          isNew: data['isNew'] ?? false,
        );
      } else {
        String errorMessage = 'Failed to verify OTP';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            // Ignore if parsing fails, use default message
          }
        }
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      return AuthResult(error: e.toString());
    }
  }

  // Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(error: 'Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return AuthResult(error: 'Failed to get ID token');
      }

      // Send the ID token to your backend
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(data['accessToken'], data['refreshToken']);

        return AuthResult(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          user: data['user'],
          isNew: data['isNew'] ?? false,
        );
      } else {
        String errorMessage = 'Failed to authenticate with Google';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            // Ignore if parsing fails, use default message
          }
        }
        return AuthResult(error: errorMessage);
      }
    } catch (e) {
      return AuthResult(error: e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await _googleSignIn.signOut();
  }
}
