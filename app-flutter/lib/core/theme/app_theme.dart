import 'package:flutter/material.dart';

/// 全局视觉：Material 3 + 暖橙种子色。
///
/// 换肤只改这里：换掉 [seed] 即可，其他控件颜色都由 ColorScheme 推导。
abstract final class AppTheme {
  static const Color seed = Color(0xFFE8503A);
  static const Color pageBackground = Color(0xFFF6F6F7);
  static const Color cardBorder = Color(0xFFECECEE);
  static const Color textSecondary = Color(0xFF7A7A80);

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: pageBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: 3,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F1F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9A9AA0)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// 没有商品图时用分类色块占位，避免首屏依赖网络图片。
  static Color categoryColor(String category) => switch (category) {
    '食品' => const Color(0xFFFFE6C7),
    '家居' => const Color(0xFFD9EFDD),
    '数码' => const Color(0xFFDCE9FB),
    '服饰' => const Color(0xFFFBDDE8),
    '手作' => const Color(0xFFE7DDF8),
    _ => const Color(0xFFE8E8EA),
  };

  static IconData categoryIcon(String category) => switch (category) {
    '食品' => Icons.bakery_dining_outlined,
    '家居' => Icons.chair_outlined,
    '数码' => Icons.devices_other_outlined,
    '服饰' => Icons.checkroom_outlined,
    '手作' => Icons.palette_outlined,
    _ => Icons.local_mall_outlined,
  };
}
