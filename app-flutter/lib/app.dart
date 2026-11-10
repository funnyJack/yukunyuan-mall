import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/product_api.dart';
import 'shell/main_shell.dart';

/// 应用根组件：只负责主题、本地化和首页入口。
class MallApp extends StatelessWidget {
  const MallApp({super.key, this.productApi});

  /// 不传时使用真实后端。测试传入假实现，避免打到网络。
  final ProductApi? productApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宇坤商城',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainShell(productApi: productApi),
    );
  }
}
