import 'package:flutter/material.dart';
import 'navigation_wrapper.dart';
import 'register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationWrapper()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Failed"),
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

  void _signUp() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB39DDB),
                          Color(0xFF7986CB),
                          Color(0xFFFF4081),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    transform: Matrix4.identity()
                      ..scale(1.0 + animation.value),
                  );
                },
              ),
              FadeTransition(
                opacity: animation,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                ),
              ),
              // Top container
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: constraints.maxHeight * (isLandscape ? 0.3 : 0.4),
                  width: double.infinity,
                  color: Colors.deepPurple[50],
                  child: Center(
                    child: Hero(
                      tag: 'wanderlogLogo',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          'WanderLog',
                          style: GoogleFonts.agbalumo(
                            textStyle: const TextStyle(
                              fontSize: 55,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B0082),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom container
              AnimatedPositioned(
                duration: const Duration(milliseconds: 0),
                bottom: isKeyboardOpen ? 0 : constraints.maxHeight * 0,
                height: isKeyboardOpen
                    ? constraints.maxHeight
                    : constraints.maxHeight * (isLandscape ? 0.7 : 0.6),
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB39DDB),
                        Color(0xFF7986CB),
                        Color(0xFFFF4081),],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isKeyboardOpen ? 0 : 30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight * (isLandscape ? 0.5 : 0.6),
                      ),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isLandscape && !isKeyboardOpen) const SizedBox(height: 85),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4B0082),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.bungee(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF4B0082),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.bungee(
                                        textStyle: const TextStyle(fontSize: 16),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
