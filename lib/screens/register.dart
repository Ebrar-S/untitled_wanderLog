import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/navigation_wrapper.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _username;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    // Save form fields to retrieve name and username
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState
          ?.save(); // This will call the onSaved for each field

      try {
        // Create the user with email and password
        UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get the current user
        User? user = userCredential.user;

        if (user != null) {
          // Add name and username to Firestore
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'name': _name,
            'username': _username,
            'email': _emailController.text.trim(),
          });

          // Navigate to the HomePage after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavigationWrapper()),
          );
        }
      } catch (e) {
        // Show error dialog if registration fails
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: const Text("Registration Failed"),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }

  void _login() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, // Removes all previous routes
    );
    print('Navigate to Login Page');
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resizing of layout
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Full-screen gradient background
              AnimatedContainer(
                duration: const Duration(milliseconds: 0),
                curve: Curves.easeInOut,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB39DDB),
                      Color(0xFF7986CB),
                      Color(0xFF7986CB),
                      Color(0xFFFF4081),
                      Color(0xFFF57C00)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomLeft,
                  ),
                ),
                height: constraints.maxHeight,
                width: constraints.maxWidth,
              ),
              // Main content
              Center(
                child: Column(
                  children: [
                    // Logo section
                    Padding(
                      padding: EdgeInsets.only(top: isPortrait ? 70.0 : 10.0),
                      child: Hero(
                        tag: 'wanderlogLogo',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            'WanderLog',
                            style: GoogleFonts.agbalumo(
                              textStyle: TextStyle(
                                fontSize: isPortrait ? 55 : 40,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4B0082),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Form Section with dynamic padding
                    Expanded(
                      flex: isPortrait ? 5 : 3,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            30.0,
                            isPortrait ? 30.0 : 10.0, // Lift form higher in landscape mode
                            30.0,
                            0.0,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _name = value;
                                  },
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _username = value;
                                  },
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4B0082),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Sign Up',
                                      style: GoogleFonts.bungee(
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white))),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _login,
                                  child: const Text(
                                      'Already have an account? Log In',
                                      style:
                                      TextStyle(color: Color(0xFF4B0082))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
