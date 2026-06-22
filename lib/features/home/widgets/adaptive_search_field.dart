import 'package:flutter/cupertino.dart';

class AdaptiveSearchField extends StatelessWidget {
  const AdaptiveSearchField({
    required this.controller,
    required this.placeholder,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
