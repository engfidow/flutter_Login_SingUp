import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loginsinup/login_page.dart';

class RegScreen extends StatefulWidget {
  RegScreen({Key? key}) : super(key: key);

  @override
  State<RegScreen> createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ConpasswordController = TextEditingController();

  bool showPassword = false;

  bool rememberMe = false;
  bool isRegistering = false;

  File? _image;
  String? uid;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void clearFields() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    ConpasswordController.clear();
    setState(() {
      _image = null;
    });
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Success'),
          content: Text('User registered successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> isUsernameTaken(String username) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isEmailTaken(String email) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> registerUser() async {
    try {
      setState(() {
        isRegistering = true;
      });

      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(usernameController.text)) {
        showErrorDialog('Username must contain only letters.');
        return;
      }

      if (await isUsernameTaken(usernameController.text)) {
        showErrorDialog('Username is already taken.');
        return;
      }

      if (await isEmailTaken(emailController.text)) {
        showErrorDialog('Email is already in use.');
        return;
      }

      if (passwordController.text != ConpasswordController.text) {
        showErrorDialog('Passwords do not match.');
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String uid = userCredential.user!.uid;
      String imageUrl =
          "https://st3.depositphotos.com/9998432/13335/v/450/depositphotos_133352156-stock-illustration-default-placeholder-profile-icon.jpg";

      if (_image != null) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('user_images/$uid.jpg');
        await storageReference.putFile(_image!);
        imageUrl = await storageReference.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': usernameController.text,
        'email': emailController.text,
        'image_url': imageUrl,
      });

      showSuccessDialog();
      clearFields();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showErrorDialog(e.message as String);
    } finally {
      setState(() {
        isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Loading Indicator
          if (isRegistering)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 100),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade500,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(200.0),
                            bottomRight: Radius.circular(200.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade300,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          "Register Account",
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundImage: _image != null
                                ? FileImage(_image!) as ImageProvider<Object>?
                                : NetworkImage(
                                    "https://st3.depositphotos.com/9998432/13335/v/450/depositphotos_133352156-stock-illustration-default-placeholder-profile-icon.jpg"),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: Icon(IconlyLight.camera),
                            ),
                          ),
                        ],
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
                          controller: usernameController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16.0),
                            labelText: "Enter user name",
                            hintText: "user name",
                            prefixIcon: Icon(IconlyLight.profile),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue.shade200, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                            hintText: "example@example.com",
                            prefixIcon: Icon(IconlyLight.message),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue.shade200, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
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
                        height: 20,
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
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue.shade200, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
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
                          controller: ConpasswordController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16.0),
                            labelText: "confirm password",
                            hintText: "Confirm Password",
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
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue.shade200, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a Confirm password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 15), // Adjust padding as needed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30.0), // Adjust radius as needed
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            registerUser();
                          }
                        },
                        child: const Text('Create Account'),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
