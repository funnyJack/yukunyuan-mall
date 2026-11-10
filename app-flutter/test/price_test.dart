import 'package:flutter_test/flutter_test.dart';
import 'package:yukunyuan_mall/core/utils/price.dart';

void main() {
  group('formatPrice', () {
    test('常规价格保留两位小数', () {
      expect(formatPrice(1250), '¥12.50');
      expect(formatPrice(5), '¥0.05');
      expect(formatPrice(100), '¥1.00');
    });

    test('千分位分隔', () {
      expect(formatPrice(129900), '¥1,299.00');
      expect(formatPrice(899900), '¥8,999.00');
      expect(formatPrice(100000000), '¥1,000,000.00');
    });

    test('价格为 0 或负数时显示面议', () {
      expect(formatPrice(0), '面议');
      expect(formatPrice(-100), '面议');
    });
  });

  group('parseYuanToCents', () {
    test('整数和一到两位小数都转成分', () {
      expect(parseYuanToCents('68'), 6800);
      expect(parseYuanToCents('68.00'), 6800);
      expect(parseYuanToCents('68.5'), 6850);
      expect(parseYuanToCents('68.50'), 6850);
      expect(parseYuanToCents('0.01'), 1);
    });

    test('超过两位小数或非数字返回 null', () {
      expect(parseYuanToCents('68.999'), isNull);
      expect(parseYuanToCents('abc'), isNull);
      expect(parseYuanToCents('-1'), isNull);
    });
  });
}
