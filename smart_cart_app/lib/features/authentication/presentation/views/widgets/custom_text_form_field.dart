import 'package:flutter/material.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.prefixIcon,
    this.obsecureText,
    this.onChanged,
    this.onSubmit,
    this.type,
    this.enabled,
    this.suffixIcon,
    required this.fieldKey, // New parameter
  });

  final Icon prefixIcon;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSubmit;
  final String label;
  final TextEditingController controller;
  final bool? obsecureText;
  final TextInputType? type;
  final bool? enabled;
  final void Function(String)? onChanged;
  final GlobalKey<FormFieldState> fieldKey; // New field key

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey, // Assign key to this field
      controller: controller,
      validator: validator,
      onFieldSubmitted: onSubmit,
      onChanged: (value) {
        fieldKey.currentState?.validate(); // Validate only this field
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      obscureText: obsecureText ?? false,
      keyboardType: type,
      enabled: enabled,
      style: const TextStyle(
        color: AppColorsLight.secondaryColor,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        prefixIconColor: AppColorsLight.secondaryColor,
        suffixIconColor: AppColorsLight.secondaryColor,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: customOutlineInputBorder(),
        border: customOutlineInputBorder(),
        focusedBorder: customOutlineInputBorder(),
        hintText: label,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  OutlineInputBorder customOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: AppColorsLight.secondaryColor),
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
    );
  }
}
