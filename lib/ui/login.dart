import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_db/ui/navigation.dart';
import 'package:movie_db/ui/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/login_preference.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isError = false;

  void _login() async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });
      print('>>>>>>>> ${_emailController.text}');
      final newUser = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      if (newUser != null) {
        print(' login successful');
        await Shared.saveLoginSharedPreference(true); // Save login state
        debugPrint(
          'DONE!!!: ${Shared.getUserSharedPreferences().toString()}',
        );

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      }
      setState(() {
        isLoading = true;
      });
    } catch (e) {
      setState(() {
        isError = true;
      });

      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          const snackBar = SnackBar(
            content: Text('Invalid email'),
            backgroundColor: CupertinoColors.systemRed,
          );
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // Handle this error gracefully, show a message to the user, or take appropriate action.
        } else if (e.code == 'invalid-password') {
          const snackBar = SnackBar(
            content: Text('Invalid password'),
            backgroundColor: CupertinoColors.systemRed,
          );
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (e.code == 'invalid-credential') {
          const snackBar = SnackBar(
            content: Text('Invalid credential'),
            backgroundColor: CupertinoColors.systemRed,
          );
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          String error = e.code;
          var snackBar = SnackBar(
            content: Text('Error: ${error}'),
            backgroundColor: CupertinoColors.systemRed,
          );
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 33, 10, 18),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 100, 25, 0),
        child: ProgressHUD(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    //strutStyle:TextStyle(textAlign:TextAlign.left,),
                    style: GoogleFonts.poppins(
                      fontSize: 55,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Back',
                    //strutStyle:TextStyle(textAlign:TextAlign.left,),
                    style: GoogleFonts.poppins(
                      fontSize: 55,
                      fontWeight: FontWeight.w600,
                      height: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 30),
                    child: Text(
                      'Sign in to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        decorationColor: Colors.grey,
                        color: Colors.white,
                      ),
                      selectionColor: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Email',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12.0),
                          labelStyle: GoogleFonts.poppins(fontSize: 16),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Password',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12.0),
                          labelStyle: GoogleFonts.poppins(fontSize: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 20.0),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 8.0),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill input')),
                            );
                          }
                        },
                        child: Text('Sign in with Facebook',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrange,
                            )),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create new account?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                          child: Text('Signup',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              )),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const Signup();
                            }));
                          })
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _login();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('islogin', true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill input')),
                            );
                          }
                        },
                        child: isLoading
                            ? Center(
                                child: SpinKitFadingCircle(
                                  color:
                                      Colors.white, // Customize color as needed
                                  size: 50.0, // Customize size as needed
                                ),
                              )
                            : Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
