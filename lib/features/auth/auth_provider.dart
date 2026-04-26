import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import 'user_model.dart';

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

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final StorageService _storage;

  AuthNotifier(this._api, this._storage) : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      try {
        final response = await _api.get(ApiConstants.users + '/me');
        if (response.data['success']) {
          state = state.copyWith(user: UserModel.fromJson(response.data['data']));
        }
      } catch (e) {
        await logout();
      }
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final userData = response.data['data'];
        final user = UserModel.fromJson(userData['user']);
        await _storage.saveTokens(
          access: userData['accessToken'],
          refresh: userData['refreshToken'],
        );
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final userData = response.data['data'];
        final user = UserModel.fromJson(userData['user']);
        await _storage.saveTokens(
          access: userData['accessToken'],
          refresh: userData['refreshToken'],
        );
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider), ref.read(storageProvider));
});
