import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 导入本地化支持包
import 'package:month_year_picker/month_year_picker.dart';
import './screens/login_screen.dart';
import './models/budget_category.dart';
import './models/budget.dart';
import './models/transaction.dart';
import './models/icon_data_adapter.dart'; // 导入你创建的IconDataAdapter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp();
  // await clearAllCache();

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

  // // 清除所有 Hive 缓存 (解除以下注释以清除缓存)
  // await clearAllCache();

  runApp(const MyApp());
}

// 清除所有 Hive 缓存的函数
Future<void> clearAllCache() async {
  Hive.deleteFromDisk();
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate, // 添加本地化委托
      ],
      supportedLocales: const [
        Locale('en', ''), // 支持的语言，可以根据需要添加其他语言
        Locale('zh', ''), // 支持中文
      ],
    );
  }
}
