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
