import 'package:flutter/material.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/widgets/text_field_input.dart';

import '../resources/auth_methods.dart';
import '../utils/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void resetPassword() {
    setState(() {
      _isLoading = true;
    });

    // Code to trigger the password reset process using AuthMethods or Firebase Auth
    // Example:
     AuthMethods().resetPassword(_emailController.text).then((result) {
       setState(() {
        _isLoading = false;
      });
      if (result == "success") {
       showSnackBar(context, "Password reset email sent!");
        Navigator.pop(context);
       } else {
         showSnackBar(context, result!);
       }
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            TextFieldInput(
              hintText: 'Enter your email',
              textInputType: TextInputType.emailAddress,
              textEditingController: _emailController, focusNode: FocusNode(),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: resetPassword,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  color: blueColorDark,
                ),
                child: !_isLoading
                    ? const Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
