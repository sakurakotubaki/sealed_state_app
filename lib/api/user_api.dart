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
