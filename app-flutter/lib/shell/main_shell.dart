import 'package:flutter/material.dart';

import '../data/product_api.dart';
import '../features/home/home_page.dart';
import '../features/profile/profile_page.dart';
import '../features/publish/publish_page.dart';
import '../features/search/search_page.dart';

/// 底部四栏骨架：首页 / 搜索 / 上架 / 我的。
///
/// 用 IndexedStack 保留各页状态（比如搜索框里已输入的关键字）。
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.productApi});

  final ProductApi? productApi;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _searchTab = 1;
  static const int _publishTab = 2;

  late final ProductApi _productApi = widget.productApi ?? HttpProductApi();
  int _index = 0;
  int _catalogVersion = 0;

  void _switchTab(int index) => setState(() => _index = index);

  void _onPublished() => setState(() => _catalogVersion++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(
            productApi: _productApi,
            reloadToken: _catalogVersion,
            onOpenPublish: () => _switchTab(_publishTab),
            onOpenSearch: () => _switchTab(_searchTab),
          ),
          SearchPage(productApi: _productApi),
          PublishPage(productApi: _productApi, onPublished: _onPublished),
          ProfilePage(onOpenPublish: () => _switchTab(_publishTab)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: '上架',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
