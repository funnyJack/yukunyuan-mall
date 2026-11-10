import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 分类胶囊按钮。
///
/// 这里不用 ChoiceChip：CanvasKit 在缺少中文字体时会用错误的字宽计算 Chip 的
/// 固有宽度，导致「全部」被裁成一个字。自绘容器由文字撑开宽度，不依赖固有尺寸。
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.transparent : AppTheme.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? scheme.primary : const Color(0xFF5A5A60),
            ),
          ),
        ),
      ),
    );
  }
}
