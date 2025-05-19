import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:global8/providers/user_provider.dart';
import 'package:global8/providers/navigation_provider.dart';
import '../resources/auth_methods.dart';
import '../responsive/mobile_screen_layout.dart' as layout;
import '../responsive/responsive_screen_layout.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/text_field_input.dart';
import 'forgot_password_screen.dart';
import 'verification_screen.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _passwordLoginController = TextEditingController();
  final TextEditingController _emailSignupController = TextEditingController();
  final TextEditingController _passwordSignupController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  double _panelPosition = 0.0;

  @override
  void dispose() {
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    _emailSignupController.dispose();
    _passwordSignupController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    final res = await AuthMethods().loginUser(
      email: _emailLoginController.text,
      password: _passwordLoginController.text,
    );

    if (res == 'success') {
      // Navigate to the main app layout, replacing the login screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResponsiveLayout(
              mobileScreenLayout: layout.MobileScreenLayout(),
              webScreenLayout: const WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      showSnackBar(context, res);
    }

    setState(() => _isLoading = false);
  }



  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      final res = await AuthMethods().signUpUser(
        email: _emailSignupController.text,
        password: _passwordSignupController.text,
        confirmpassword: _confirmPasswordController.text,
      );

      if (res == "success") {
        final verificationRes = await AuthMethods().sendVerificationEmail();
        if (verificationRes.toLowerCase() == "email sent") {
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            // Directly push the EmailVerificationScreen using Navigator
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EmailVerificationScreen(),
              ),
            );
          }
        } else {
          showSnackBar(context, verificationRes);
        }
      } else {
        showSnackBar(context, res);
      }
    } catch (e) {
      showSnackBar(context, "An error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColorDark,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/image.png"),
            fit: BoxFit.none,
            scale: 5,
            alignment: Alignment(0, -.42),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withAlpha(60),
              blurRadius: 6.0,
              offset: const Offset(0.0, 3.0),
            ),
          ],
          gradient: RadialGradient(
            radius: .5,
            colors: [Colors.black, Colors.white.withOpacity(.5), Colors.white.withAlpha(0)],
          ),
        ),
        child: Opacity(
          opacity: 0.8,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_panelPosition < 0.1)
                    Column(
                      children: const [
                        GlowText("Swipe up", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 60.0, fontWeight: FontWeight.w400)),
                        GlowText("to get started!", textAlign: TextAlign.center, style: TextStyle(color: Colors.purple, fontSize: 50.0, fontWeight: FontWeight.w400)),
                        SizedBox(height: 120),
                      ],
                    ),
                  SlidingUpPanel(
                    onPanelSlide: (double pos) => setState(() => _panelPosition = pos),
                    renderPanelSheet: false,
                    panel: Container(
                      margin: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(75, 55, 196, 0.22),
                        border: Border.all(color: Colors.deepPurpleAccent),
                        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            if (_panelPosition < 0.1)
                              const Icon(Icons.keyboard_arrow_up, size: 50, color: Colors.purple),
                            const SizedBox(height: 10),
                            if (_panelPosition > 0.1)
                              const TabBar(
                                indicatorColor: Colors.deepPurpleAccent,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                tabs: [Tab(text: "Sign In"), Tab(text: "Sign Up")],
                              ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildLoginTab(),
                                  _buildSignupTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const GlowText("Welcome!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 40)),
          const SizedBox(height: 24),
          TextFieldInput(
            hintText: 'Enter your Email',
            textInputType: TextInputType.emailAddress,
            textEditingController: _emailLoginController,
            boxShadow: true,
            focusNode: FocusNode(),
          ),
          const SizedBox(height: 24),
          TextFieldInput(
            hintText: 'Enter your Password',
            textInputType: TextInputType.text,
            textEditingController: _passwordLoginController,
            isPass: true,
            boxShadow: true,
            focusNode: FocusNode(),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _loginUser,
            child: Container(
              width: 100,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                color: blueColorDark,
              ),
              child: !_isLoading
                  ? const Text('Log in', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold))
                  : const CircularProgressIndicator(color: primaryColorDark),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
              );
            },
            child: const Text('Forgot password?'),
          ),

        ],
      ),
    );
  }

  Widget _buildSignupTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const GlowText("Get on Board.", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w400)),
          const SizedBox(height: 15),
          TextFieldInput(
            hintText: 'Enter your E-mail',
            textInputType: TextInputType.emailAddress,
            textEditingController: _emailSignupController,
            boxShadow: true,
            focusNode: FocusNode(),
          ),
          const SizedBox(height: 15),
          TextFieldInput(
            hintText: 'Password',
            textInputType: TextInputType.text,
            textEditingController: _passwordSignupController,
            isPass: true,
            boxShadow: true,
            focusNode: FocusNode(),
          ),
          const SizedBox(height: 15),
          TextFieldInput(
            hintText: 'Confirm Password',
            textInputType: TextInputType.text,
            textEditingController: _confirmPasswordController,
            isPass: true,
            boxShadow: true,
            focusNode: FocusNode(),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _signUp,
            child: Container(
              width: 100,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                color: blueColorDark,
              ),
              child: !_isLoading
                  ? const Text('Sign up', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold))
                  : const CircularProgressIndicator(color: primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }
}

