import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 我的页面：占位版，只有身份信息和入口，登录/店铺管理后续再做。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onOpenPublish});

  final VoidCallback onOpenPublish;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  '宇',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '宇坤的小店',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '成员编号 #10001',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你还没有上架商品',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '上架第一件商品后，就可以购买其他成员的商品了。',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 140,
                  child: FilledButton(
                    onPressed: onOpenPublish,
                    child: const Text('去上架商品'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _StatCard(label: '在售', value: '0'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(label: '已售', value: '0'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(label: '收藏', value: '0'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _MenuTile(icon: Icons.inventory_2_outlined, title: '我的商品'),
          const _MenuTile(icon: Icons.receipt_long_outlined, title: '我的订单'),
          const _MenuTile(icon: Icons.location_on_outlined, title: '收货地址'),
          const _MenuTile(icon: Icons.info_outline, title: '关于宇坤商城'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22, color: const Color(0xFF5A5A60)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: Color(0xFFB9B9C0),
      ),
      onTap: () =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('「$title」页面还没做'))),
    );
  }
}
