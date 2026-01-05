import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String name;
  final String email;
  final double balance;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['fullName'] as String? ?? 'User',
      email: json['email'] as String,
      balance:
          0.0, // Backend doesn't send balance in login response yet, default to 0
    );
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final String? token;

  const AuthState({this.user, this.isLoading = false, this.error, this.token});

  bool get isAuthenticated => user != null;
}

class AuthController extends Notifier<AuthState> {
  final Dio _dio = Dio();

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);

    try {
      // Use localhost:3000 for simple testing.
      // For Android Emulator use 10.0.2.2.
      // For real device use IP address.
      const baseUrl = 'http://localhost:3000/api/auth';

      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final token = data['token'];
      final user = User.fromJson(data['user']);

      state = AuthState(user: user, token: token, isLoading: false);
    } on DioException catch (e) {
      String errorMessage = "Login failed";
      if (e.response != null) {
        errorMessage =
            e.response?.data['error'] ??
            e.response?.statusMessage ??
            "Server Error";
      } else {
        errorMessage = e.message ?? "Connection Error";
      }
      state = AuthState(isLoading: false, error: errorMessage);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
