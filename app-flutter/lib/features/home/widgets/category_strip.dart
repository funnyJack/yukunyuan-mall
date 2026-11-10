import 'package:flutter/material.dart';

import '../../../core/widgets/category_pill.dart';
import '../../../data/mock_products.dart';

/// 分类横滑条：选中后由父组件做本地筛选。
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final String category = kCategories[index];
          return Center(
            child: CategoryPill(
              label: category,
              selected: category == selected,
              onTap: () => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}
