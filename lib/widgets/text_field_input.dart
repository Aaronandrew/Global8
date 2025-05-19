import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController textEditingController;
  final bool isPass;
  final bool boxShadow;

   const TextFieldInput({
    required this.hintText,
    required this.textInputType,
    required this.textEditingController,
    this.isPass = false,
    this.boxShadow = false,
    required FocusNode focusNode,
  });

  @override
  _TextFieldInputState createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: widget.boxShadow
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: TextField(
        controller: widget.textEditingController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          suffixIcon: widget.isPass
              ? IconButton(
            icon: Icon(
             _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
             // color: Colors.black.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
        ),
        // Only obscure if it's a password
         keyboardType: TextInputType.visiblePassword,
        obscureText: widget.isPass && !_isPasswordVisible,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
