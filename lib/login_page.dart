import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:loginsinup/CustomSlidersScreen.dart';
import 'package:loginsinup/signup_page.dart';
import 'package:loginsinup/slide_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool rememberMe = false;
  bool isLoading = false; // Added state for loading indicator
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String errorMessage = ''; // Added state for error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.blue, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        "assets/user.png",
                        fit: BoxFit.cover,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white60,
                          blurRadius: 10.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16.0),
                        labelText: "Enter user email address",
                        hintText: "For example: example@example.com",
                        prefixIcon: Icon(IconlyLight.profile),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue.shade200, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white60,
                          blurRadius: 10.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      obscureText: !showPassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16.0),
                        labelText: "Enter password",
                        hintText: "Password",
                        prefixIcon: Icon(
                          IconlyLight.lock,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          child: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue.shade200, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember me'),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Add logic for Forgot Password
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        try {
                          setState(() {
                            isLoading = true; // Set loading state
                          });

                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                          print(
                              'Login successful: ${userCredential.user?.uid}');
                          if (rememberMe) {
                            // Save user credentials for auto-login
                            await _secureStorage.write(
                              key: 'userEmail',
                              value: emailController.text,
                            );
                            // You may want to encrypt and securely store the password as well.
                            // For simplicity, it's recommended to use a dedicated authentication solution like Firebase Auth.
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Login success!: ${emailController.text}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SlideScreen(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          print('Login failed: ${e.message}');
                          setState(() {
                            errorMessage = 'Incorrect email or password';
                          });
                          // Show error message using SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login failed: ${errorMessage}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() {
                            isLoading = false; // Reset loading state
                          });
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "don't have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegScreen(),
                            ),
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
