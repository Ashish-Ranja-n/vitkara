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

  // Used by static Google sign-in to store a single token (backend may return a single JWT)
  static Future<void> saveToken(String? token) async {
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  // Store user data as JSON string (used by static Google sign-in)
  static Future<void> saveUserData(Map<String, dynamic>? user) async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user));
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
      // Sign out first to ensure fresh sign-in
      await _googleSignIn.signOut();

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(error: 'Google sign-in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        return AuthResult(error: 'Failed to get Google access token');
      }

      // Send the access token to your backend mobile endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          // Store the token using the correct key
          await saveToken(data['token']);
          await saveUserData(data['user']);

          return AuthResult(
            accessToken: data['token'],
            user: data['user'],
            isNew: data['isNew'] ?? false,
          );
        } else {
          return AuthResult(error: data['message'] ?? 'Google sign-in failed');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          return AuthResult(
            error: errorData['message'] ?? 'Server error during Google sign-in',
          );
        } catch (parseError) {
          return AuthResult(error: 'Server error: ${response.statusCode}');
        }
      }
    } on FormatException {
      return AuthResult(error: 'Invalid response format from server');
    } on http.ClientException {
      return AuthResult(
        error: 'Connection failed. Please check your internet connection.',
      );
    } catch (e) {
      return AuthResult(error: 'Google sign-in error: ${e.toString()}');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
    await _googleSignIn.signOut();
  }
}
