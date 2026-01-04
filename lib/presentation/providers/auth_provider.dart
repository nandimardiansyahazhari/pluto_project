import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String name;
  final String email;
  final double balance;

  const User({required this.name, required this.email, required this.balance});
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API

    if (email.isNotEmpty && password.length >= 6) {
      state = const AuthState(
        user: User(name: "Ansyah Gamer", email: "ansyah@pluto.com", balance: 150000),
        isLoading: false,
      );
    } else {
      state = const AuthState(isLoading: false, error: "Invalid credentials");
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
