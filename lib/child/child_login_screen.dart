import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:willow/child/bottom_page.dart';
import 'package:willow/components/primary_button.dart';
import 'package:willow/components/secondary_button.dart';
import 'package:willow/components/custom_textfield.dart';
import 'package:willow/child/register_child.dart';
import 'package:willow/db/share_pref.dart';
import 'package:willow/parent/parent_register_screen.dart';
import 'package:willow/utils/constants.dart';
import 'package:willow/parent/parent_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordShown = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  _onSubmit() async {
    _formKey.currentState!.save();

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _formData['email'].toString(),
        password: _formData['password'].toString(),
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (userCredential.user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((value) {
          if (mounted) {
            print("====> ${value['type']}");
            if (value['type'] == 'parent') {
              MySharedPreference.saveUserType('parent');
              goTo(context, const ParentHomeScreen());
            } else {
              MySharedPreference.saveUserType('child');
              goTo(context, const BottomPage());
            }
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (e.code == 'user-not-found') {
        dialogueBox(context, 'No user found for that email.');
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        dialogueBox(context, 'Wrong password provided for that user.');
        print('Wrong password provided for that user.');
      }
    }

    print(_formData['email']);
    print(_formData['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                isLoading
                    ? progressIndicator(context)
                    : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              "USER LOGIN",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: kColorRed),
                            ),
                            Image.asset(
                              'assets/logo.png',
                              height: 100,
                              width: 100,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomTextField(
                                hintText: 'enter email',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.emailAddress,
                                prefix: const Icon(Icons.person),
                                onsave: (email) {
                                  _formData['email'] = email ?? "";
                                },
                                validate: (email) {
                                  if (email!.isEmpty ||
                                      email.length < 3 ||
                                      !email.contains("@")) {
                                    return 'enter correct email';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                hintText: 'enter password',
                                isPassword: isPasswordShown,
                                prefix: const Icon(Icons.vpn_key_rounded),
                                validate: (password) {
                                  if (password!.isEmpty ||
                                      password.length < 7) {
                                    return 'enter correct password';
                                  }
                                  return null;
                                },
                                onsave: (password) {
                                  _formData['password'] = password ?? "";
                                },
                                suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isPasswordShown = !isPasswordShown;
                                      });
                                    },
                                    icon: isPasswordShown
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility)),
                              ),
                              PrimaryButton(
                                  title: 'LOGIN',
                                  onPressed: () {
                                    // progressIndicator(context);
                                    if (_formKey.currentState!.validate()) {
                                      _onSubmit();
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Forgot Password?",
                              style: TextStyle(fontSize: 18),
                            ),
                            SecondaryButton(
                                title: 'click here', onPressed: () {}),
                          ],
                        ),
                      ),
                      SecondaryButton(
                          title: 'Register as child',
                          onPressed: () {
                            goTo(context, const RegisterChildScreen());
                          }),
                      SecondaryButton(
                          title: 'Register as Parent',
                          onPressed: () {
                            goTo(context, const RegisterParentScreen());
                          }),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}



