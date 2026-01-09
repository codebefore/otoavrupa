import 'package:flutter/foundation.dart';
import '../models/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Login with phone number
  Future<void> sendOtp(String phoneNumber) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Success
      _status = AuthStatus.unauthenticated; // Waiting for OTP verification
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Verify OTP
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement API call
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Create dummy user for testing
      _user = User(
        id: '1',
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // TODO: Clear tokens, etc.
      await Future.delayed(const Duration(seconds: 1));

      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
