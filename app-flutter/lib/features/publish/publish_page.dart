import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/price.dart';
import '../../core/widgets/category_pill.dart';
import '../../data/api_exception.dart';
import '../../data/mock_products.dart';
import '../../data/product_api.dart';
import '../../models/product.dart';

/// 上架商品页：校验通过后调用 `POST /api/products`。
class PublishPage extends StatefulWidget {
  const PublishPage({
    super.key,
    required this.productApi,
    required this.onPublished,
  });

  final ProductApi productApi;
  final VoidCallback onPublished;

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = '手作';
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final String title = _titleController.text.trim();
    final int priceCents = parseYuanToCents(_priceController.text.trim())!;
    setState(() => _submitting = true);
    try {
      await widget.productApi.create(
        ProductDraft(
          title: title,
          priceCents: priceCents,
          category: _category,
          description: _descriptionController.text.trim(),
          sellerName: '宇坤的小店',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('「$title」已上架')));
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() => _category = '手作');
      widget.onPublished();
    } on ApiException catch (error) {
      if (!mounted) return;
      final String detail = error.fieldErrors.values.isEmpty
          ? error.message
          : error.fieldErrors.values.first;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(detail)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> publishCategories = kCategories.sublist(1);
    return Scaffold(
      appBar: AppBar(title: const Text('上架商品')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '每个成员至少上架一件商品，商城才会对你开放购买。',
                  style: TextStyle(fontSize: 12.5, height: 1.5),
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('商品名称'),
              TextFormField(
                controller: _titleController,
                maxLength: 30,
                decoration: const InputDecoration(hintText: '例如：手工皂礼盒（三块装）'),
                validator: (value) {
                  final String text = (value ?? '').trim();
                  if (text.isEmpty) return '请填写商品名称';
                  if (text.length < 2) return '名称至少 2 个字';
                  return null;
                },
              ),
              const SizedBox(height: 6),
              const _FieldLabel('价格（元）'),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(hintText: '例如：68.00'),
                validator: (value) {
                  final int? priceCents = parseYuanToCents(
                    (value ?? '').trim(),
                  );
                  if (priceCents == null) return '请填写数字价格，最多两位小数';
                  if (priceCents <= 0) return '价格需要大于 0';
                  if (priceCents > 100000000) return '价格看起来太大了';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const _FieldLabel('分类'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final String category in publishCategories)
                    CategoryPill(
                      label: category,
                      selected: _category == category,
                      onTap: () => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const _FieldLabel('商品描述'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: '成色、规格、发货方式、注意事项……',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? '正在上架…' : '提交上架'),
              ),
              const SizedBox(height: 10),
              const Text(
                '提交后会写入商城，首页下拉即可看到。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
