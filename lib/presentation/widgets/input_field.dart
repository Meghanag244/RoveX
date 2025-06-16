import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const InputField({
    Key? key,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontSize: 18,
          ),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
} 