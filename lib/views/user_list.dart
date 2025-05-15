import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sealed_state_app/api/user_api.dart';
import 'package:sealed_state_app/state/user_state.dart';

/// APIから取得したユーザー情報を表示するウィジェット
class UserList extends StatefulWidget {
  final Dio dio;
  const UserList({super.key, required this.dio});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  /// Dioインスタンスを使用してAPIからユーザー情報を取得する
  late UserApi _userApi;
  /// ユーザー情報の取得状態を管理する
  UserFetchState _state = Loading();

  /// ウィジェットの初期化時にAPIからユーザー情報を取得する
  @override
  void initState() {
    super.initState();
    _userApi = UserApi(widget.dio);
    _fetchUsers();
  }

  /// APIからユーザー情報を取得するメソッド
  Future<void> _fetchUsers() async {
    try {
      /// ユーザー情報を取得中の状態
      setState(() {
        _state = Loading();
      });
      /// APIからユーザー情報を取得
      final users = await _userApi.getUsers();
      
      /// ユーザー情報を取得に成功した状態
      setState(() {
        _state = Success(users);
      });
    } catch (e) {
      /// ユーザー情報の取得に失敗した状態
      setState(() {
        _state = Error(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        /// switch文を使用して、状態に応じたウィジェットを表示
        child: switch (_state) {
          /// ローディング状態のウィジェット
          Loading() => const Center(
              child: CircularProgressIndicator(),
            ),
          /// データ取得状態のウィジェット
          Success(users: final users) => users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user.name.substring(0, 1)),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Text('@${user.username}'),
                      ),
                    );
                  },
                ),
          /// エラー状態のウィジェット
          Error(message: final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $message'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}