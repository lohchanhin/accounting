import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './screens/login_screen.dart';
import './models/budget_category.dart';
import './models/budget.dart';
import './models/transaction.dart';
import './models/icon_data_adapter.dart'; // 导入你创建的IconDataAdapter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp();

  // 初始化 Hive
  await Hive.initFlutter();

  // 注册 Hive 适配器
  Hive.registerAdapter(BudgetCategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(TransactionAdapter());
  // 注册 IconData 的适配器
  Hive.registerAdapter(IconDataAdapter());

  // 打开 Hive 缓存箱
  await Hive.openBox('cacheBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounting App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
