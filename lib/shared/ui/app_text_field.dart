import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text field using theme. No hardcoded colors.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        fillColor: theme.colorScheme.surface,
      ),
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
