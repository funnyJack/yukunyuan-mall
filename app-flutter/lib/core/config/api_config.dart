import 'package:flutter/foundation.dart';

/// 开发期后端根地址，不含 `/api`。
///
/// 可用编译参数覆盖，例如真机调试：
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080`
String resolveApiBaseUrl() {
  const String fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kIsWeb) return 'http://localhost:8080';
  if (defaultTargetPlatform == TargetPlatform.android) {
    // 模拟器里的 localhost 是模拟器自己，10.0.2.2 才是宿主机。
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}
