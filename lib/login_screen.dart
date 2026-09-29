import 'dart:ui';
import 'package:flutter/material.dart';
import 'main_wrapper.dart'; 

class GlassLoginScreen extends StatefulWidget {
  const GlassLoginScreen({super.key});
  @override
  State<GlassLoginScreen> createState() => _GlassLoginScreenState();
}

class _GlassLoginScreenState extends State<GlassLoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 1. सामान्य ईमेल लॉगिन (Bypass for Testing)
  void _handleLogin() async {
    // TODO: Restore real Email/Password authentication
    /*
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
      }
    } catch (e) {
      _showMessage("Login Failed: ${e.toString()}");
    }
    setState(() => _isLoading = false);
    */

    // Test Mode: Direct Navigation
    _showMessage("Test Mode: Logging in without Auth...");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
  }

  // 2. गूगल लॉगिन (Bypass for Testing)
  Future<void> _handleGoogleSignIn() async {
    // TODO: Restore real Google Sign-In authentication
    /*
    setState(() => _isLoading = true);
    try {
      await GoogleSignIn().signOut(); 
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
        }
      }
    } catch (e) {
      _showMessage("Google Login Error: $e");
    }
    setState(() => _isLoading = false);
    */

    // Test Mode: Direct Navigation
    _showMessage("Test Mode: Logging in via Google Bypass...");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_mobile.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    height: 120, width: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset('assets/app_logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 350,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildInputField("Email", Icons.email_outlined, _emailController),
                            const SizedBox(height: 25),
                            _buildPasswordField(),
                            const SizedBox(height: 15),
                            _buildLoginButton(), 
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text("Or login with", style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIconButton(Icons.apple, () {
                        _showMessage("Test Mode: Apple Login Bypass");
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
                      }),
                      const SizedBox(width: 25),
                      _socialIconButton(Icons.g_mobiledata_rounded, _handleGoogleSignIn, isGoogle: true),
                      const SizedBox(width: 25),
                      _socialIconButton(Icons.facebook, () {
                        _showMessage("Test Mode: Facebook Login Bypass");
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
                      }, isFB: true),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        hintText: "Password",
        hintStyle: const TextStyle(color: Colors.white60),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
          : const Text("Login"),
      ),
    );
  }

  Widget _socialIconButton(IconData icon, VoidCallback action, {bool isGoogle = false, bool isFB = false}) {
    return GestureDetector(
      onTap: action,
      child: Icon(
        icon, 
        color: isGoogle ? Colors.orange : (isFB ? Colors.blue : Colors.white), 
        size: 40
      ),
    );
  }
}