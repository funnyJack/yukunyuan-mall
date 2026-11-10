/// 把「分」格式化成人民币字符串。
///
/// 全项目金额统一用 `int` 存「分」：后端 JSON 也返回分，避免 double 的精度问题。
/// - [cents] 小于等于 0 时返回「面议」（赠品、未定价）
/// - 千分位分隔，固定两位小数
String formatPrice(int cents) {
  if (cents <= 0) return '面议';
  final int yuan = cents ~/ 100;
  final int fen = cents % 100;
  final String digits = yuan.toString();
  final StringBuffer buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '¥$buffer.${fen.toString().padLeft(2, '0')}';
}

/// 把用户输入的「元」转成「分」。
///
/// 只接受非负整数，或最多两位小数。`68`、`68.5`、`68.50` 都可以，`68.999` 返回 null。
int? parseYuanToCents(String raw) {
  final RegExp pattern = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');
  final Match? match = pattern.firstMatch(raw.trim());
  if (match == null) return null;
  final int yuan = int.parse(match.group(1)!);
  final String fenText = (match.group(2) ?? '').padRight(2, '0');
  final int fen = int.parse(fenText);
  return yuan * 100 + fen;
}
