import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global8/resources/auth_methods.dart';
import 'package:global8/responsive/mobile_screen_layout.dart';
import 'package:global8/responsive/responsive_screen_layout.dart';
import 'package:global8/responsive/web_screen_layout.dart';
import 'package:global8/screens/login_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/utils/global_variable.dart';
import 'package:global8/utils/utils.dart';
import 'package:global8/widgets/text_field_input.dart';
import 'package:flutter_glow/flutter_glow.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our authmethodds
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!);
    // if string returned is sucess, user has been created
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      if (context.mounted) {
        showSnackBar(context, res);
      }
    }
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(

        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assests/images/image.png"),
              fit: BoxFit.none, // Allow scaling
              scale: 8,
              alignment: Alignment(0, -.8)
            //fit: BoxFit.cover,
          ),
          gradient:  RadialGradient(
            // center: Alignment.bottomCenter,
            focalRadius: 5, // Adjust the radius as needed
            colors: [Colors.black, Colors.white.withOpacity(.5), Colors.white.withAlpha(0)],


          ),
        ),

        child: SafeArea(

        child: Container(
          alignment: Alignment.bottomCenter,
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 30,
                child: Container(),
              ),
              const SizedBox(
                height: 64,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                    radius: 64,
                    backgroundImage: MemoryImage(_image!),
                    backgroundColor: Colors.purple,
                  )
                      : const CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(
                        'https://i.stack.imgur.com/l60Hf.png'),
                    backgroundColor: Colors.white,
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
              const GlowText(
                "Get on Board.",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 15,
              ),

              TextFieldInput(
                hintText: 'Enter your Username',
                textInputType: TextInputType.text,
                textEditingController: _usernameController,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldInput(
                hintText: 'Enter your E-mail',
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(
                height: 15,
              ),

              TextFieldInput(
                hintText: 'Enter your Password',
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                isPass: true,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldInput(
                hintText: 'Enter your bio',
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),
              const SizedBox(
                height: 24,
              ),

             /* TextFieldInput(
                hintText: 'bio',
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),*/
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: signUpUser,
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
                    'Sign up', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  )
                      : const CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Already have an account?',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const GlowText(
                        ' Login.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}