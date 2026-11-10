import 'package:flutter/material.dart';

/// 把「每个人既是卖家也是买家」这条规则放在首屏最显眼的位置。
class StorePromptBanner extends StatelessWidget {
  const StorePromptBanner({super.key, required this.onOpenPublish});

  final VoidCallback onOpenPublish;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.storefront_outlined, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '成员制商城：先开店，才能买',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '上架一件商品即可解锁购买权限',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onOpenPublish, child: const Text('去上架')),
        ],
      ),
    );
  }
}
