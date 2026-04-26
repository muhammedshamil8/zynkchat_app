import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class UserListNotifier extends Notifier<List<UserModel>> {
  @override
  List<UserModel> build() {
    Future.microtask(() => fetchUsers());
    return [];
  }

  Future<void> fetchUsers() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.get(ApiConstants.users);
      if (response.data['success']) {
        final List data = response.data['data'];
        state = data.map((json) => UserModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error
    }
  }
}

final userListProvider = NotifierProvider<UserListNotifier, List<UserModel>>(UserListNotifier.new);
