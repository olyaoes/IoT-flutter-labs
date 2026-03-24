import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    required this.hint,
    this.isPass = false,
    super.key,
  });

  final String hint;
  final bool isPass;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        obscureText: isPass,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.7),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 22,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
