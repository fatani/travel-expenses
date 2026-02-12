import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, this.controller, this.hintText});

  final TextEditingController? controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: Directionality.of(context),
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
