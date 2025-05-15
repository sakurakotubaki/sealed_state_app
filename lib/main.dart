import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:sealed_state_app/views/user_list.dart';

void main() {
  // Dioのインスタンスを作成
  final dio = Dio();
  
  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;
  
  const MyApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sealed State App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      /// APIから取得したユーザー情報を表示するウィジェットを表示
      home: UserList(dio: dio),
    );
  }
}