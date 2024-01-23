import 'package:flutter/material.dart';
import 'package:global8/resources/auth_methods.dart';
import 'package:global8/responsive/mobile_screen_layout.dart';
import 'package:global8/responsive/responsive_screen_layout.dart';
import 'package:global8/responsive/web_screen_layout.dart';
import 'package:global8/screens/signup_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/utils/global_variable.dart';
import 'package:global8/utils/utils.dart';
import 'package:global8/widgets/text_field_input.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:avatar_glow/avatar_glow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  final double _panelPosition = 0.0;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  double _panelPosition = 0.0;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
              (route) => false);

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(

      decoration: BoxDecoration(

       image: const DecorationImage(
        image:  AssetImage("assests/images/image.png", ),
        fit: BoxFit.none, // Allow scaling
        scale: 5,
        alignment: Alignment(0, -.42)

        ),

        boxShadow: [BoxShadow(
           color: const Color(0xFF000000).withAlpha(60),
           blurRadius: 6.0,
           spreadRadius: 0.0,
           offset: const Offset(0.0, 3.0,),
           ),
        ],

        gradient:  RadialGradient(
         // center: Alignment.bottomCenter,
          radius:.5, // Adjust the radius as needed
          colors: [Colors.black, Colors.white.withOpacity(.5), Colors.white.withAlpha(0)],
          //focal: Alignment.bottomCenter
        ),
      ),


       child: Opacity(

         opacity: 0.8, // Adjust the opacity as needed


         child: Column(
           //crossAxisAlignment: CrossAxisAlignment.center,
           //mainAxisSize: MainAxisSize.max,
           mainAxisAlignment: MainAxisAlignment.end,
           children: [ Visibility(
             visible: _panelPosition < 0.1, // Adjust the threshold as needed
                 child: const Positioned(
                    bottom: 16.0,
                    left: 0,
                    right: 0,
                 child: Column(

                 children: [
                   GlowText(
                   "Swipe up",
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 60.0,
                     fontWeight: FontWeight.w400,




                   ),),
                   GlowText(
                              "to get started!",
                     textAlign: TextAlign.center,
                          style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 50.0,
                                            fontWeight: FontWeight.w400,




                          ),
                         ),
                   const SizedBox(
                     height: 120,

                   ),],
                        ),
                 ),
           ),



          SlidingUpPanel(

      onPanelSlide: (double position) {
        setState(() {
          _panelPosition = position;
        });
      },
      renderPanelSheet: false,

          panel:  Container(

            margin: const EdgeInsets.all(1.0),
            // padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(

              color: const Color.fromRGBO(75, 55, 196, 0.2196078431372549),
              border: Border.all(color: Colors.deepPurpleAccent),
              borderRadius: const BorderRadius.all(
                  Radius.circular(50.0) //                 <--- border radius here
              ),

            ),

            padding: MediaQuery.of(context).size.width > webScreenSize
                ? EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width/3)
                : const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,

            child: SafeArea(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                  Container(
                    width: 100,
                    height: 15,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)),
                    ),
                    margin: const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),

                  ),
                  const SizedBox(
                    height: 24,

                  ),

                  const GlowText(
                    "Welcome!",
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 40 ),
                  ),
                  const SizedBox(
                    height: 24,

                  ),

                  TextFieldInput(
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                  const SizedBox(
                    height: 24,

                  ),
                  TextFieldInput(
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InkWell(
                    onTap: loginUser,
                    child: Container(
                      width: 100,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        color: blueColor,
                      ),
                      child: !_isLoading
                          ? const GlowText(
                        'Log in', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                      )
                          : const CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          "Don't have an account?",
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const GlowText(
                            ' Signup.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),],
                  ),
                ],),
            ),
          ),
          collapsed:Container(

            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
            ),
            margin: const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
            child: const AvatarGlow(
              //endRadius: 100,
              endRadius: 100,
              duration: Duration(milliseconds: 2000),
              repeatPauseDuration: Duration(milliseconds: 100),
              //endRadius: 100,
              child: GlowIcon( Icons.keyboard_double_arrow_up_outlined, glowColor: Colors.purple,  size: 80,
              ),

            ),
          ) ,

         ),],
// Add the Visibility widget below the SlidingUpPanel
        ),

       ),
      ),
    );
  }

}

