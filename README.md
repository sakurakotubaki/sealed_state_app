# sealed_state_app
海外の記事を参考に、sealed classを活用してみる。

[Flutter Enums in Flutter with Sealed Classes in Dart 3](https://blog.stackademic.com/enums-in-flutter-with-sealed-classes-in-dart-3-d67a312da549)

HTTP通信に必要なライブラリをインストールする、

[dio](https://pub.dev/packages/dio)

[{JSON} Placeholder](https://jsonplaceholder.typicode.com/)からAPIのデータを取得する。

[users](https://jsonplaceholder.typicode.com/users)から取得する。


### モデルを作成
APIのJSONの構造に合わせて、モデルを作成する。
```dart
class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });

  /// HTTP GETだけなので、fromJsonだけでOK
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
    );
  }
}
```

### APIからデータを取得する
dioを使用して、HTTP GETしてデータを取得する。

```dart
import 'package:dio/dio.dart';
import 'package:sealed_state_app/model/user_model.dart';

/// APIからユーザー情報を取得するクラス
class UserApi {
  final Dio _dio;

  UserApi(this._dio);

  Future<List<UserModel>> getUsers() async {
    try {
      const url = 'https://jsonplaceholder.typicode.com/users';
      /// 取得したデータを格納するリスト
      List<UserModel> users = [];
      /// Dioを使用してAPIからデータを取得
      final response = await _dio.get(url);
      /// ステータスコードが200の場合、データをリストに格納
      if (response.statusCode == 200) {
        /// 取得したデータをリストに格納
        /// response.dataはList<dynamic>型なので、UserModelに変換する
        for (var user in response.data) {
          users.add(UserModel.fromJson(user));
        }
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}
```

### sealed classを定義
データの取得状態によって、sealed classを使用して、Widgetを切り替える。
直和表現と呼ばれていることもある。　

```dart
import 'package:sealed_state_app/model/user_model.dart';

/// データの取得状態で使用するsealed class
sealed class UserFetchState {}

/// ローディング状態のクラス
class Loading extends UserFetchState {}

/// データを取得した後の状態
class Success extends UserFetchState {
  final List<UserModel> users;
  Success(this.users);
}

/// エラー状態のクラス
class Error extends UserFetchState {
  final String message;
  Error(this.message);
}
```

直和表現（Union Type）とは、複数の型のうちどれか1つの値をとりうる型のことです。数学の集合論における「直和集合」から名前がつけられており、代数的データ型（ADT）の一種です。
具体的に説明すると:
複数の型のいずれか1つ:例えば、文字列（String）または数字（Number）のどちらかを表現できる型です.
代数的データ型:直和型は、代数的データ型の一種で、代数的データ型は、他の型を組み合わせることで新しい型を定義する仕組みです.﻿
実装:Dartでは、sealed classを使用して直和型を実装できます.

### データを表示する
View側ではデータの取得状態で、表示を切り替えるのに上で定義したsealed classを使用します。

```dart
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
```