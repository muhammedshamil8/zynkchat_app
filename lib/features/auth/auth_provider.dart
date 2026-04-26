import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import 'user_model.dart';
import '../../core/utils/snackbar_utils.dart';

// Service Providers
final storageProvider = Provider((ref) => StorageService());
final apiServiceProvider = Provider((ref) => ApiService(ref.read(storageProvider)));

// Auth State Class
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier (Modern Riverpod 3.0 Notifier)
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check for existing session in the background
    Future.microtask(() => checkAuth());
    return AuthState(isLoading: true);
  }

  Future<void> checkAuth() async {
    final storage = ref.read(storageProvider);
    final api = ref.read(apiServiceProvider);
    
    final token = await storage.getAccessToken();
    if (token != null) {
      try {
        // Add a 3-second timeout to prevent getting stuck
        final response = await api.get('${ApiConstants.users}/profile').timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Connection timed out'),
        );

        if (response.data['success']) {
          final user = UserModel.fromJson(response.data['data']);
          state = state.copyWith(user: user, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      } catch (e) {
        print('Auth check failed: $e');
        state = state.copyWith(isLoading: false);
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final api = ref.read(apiServiceProvider);
    final storage = ref.read(storageProvider);

    state = state.copyWith(isLoading: true);
    try {
      final response = await api.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final userData = response.data['data'];
        final user = UserModel.fromJson(userData['user']);
        await storage.saveTokens(
          access: userData['accessToken'],
          refresh: userData['refreshToken'],
        );
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(isLoading: false, error: errorMsg);
      SnackbarUtils.showError('Registration failed: Please check your details');
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    final api = ref.read(apiServiceProvider);
    final storage = ref.read(storageProvider);

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await api.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final userData = response.data['data'];
        final user = UserModel.fromJson(userData['user']);
        await storage.saveTokens(
          access: userData['accessToken'],
          refresh: userData['refreshToken'],
        );
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      SnackbarUtils.showError('Login failed: Invalid email or password');
    }
    return false;
  }

  Future<void> logout() async {
    final storage = ref.read(storageProvider);
    await storage.clearAuth();
    state = AuthState();
  }
}

// Global Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
