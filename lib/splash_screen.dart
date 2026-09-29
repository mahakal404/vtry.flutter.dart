import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;
  
  String _displayedText = "";
  int _charIndex = 0;
  final String _fullText = "V-Try";

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); 

    _shineAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    Timer(const Duration(milliseconds: 800), _typeText);

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GlassLoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void _typeText() {
    if (_charIndex < _fullText.length && mounted) {
      setState(() {
        _displayedText += _fullText[_charIndex];
        _charIndex++;
      });
      Future.delayed(const Duration(milliseconds: 150), _typeText);
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 600;
          String splashImage = isDesktop ? 'assets/splash_desktop.png' : 'assets/splash_mobile.png';

          return Stack(
            children: [
              // 1. पूरी स्क्रीन पर फैलने वाली बैकग्राउंड इमेज
              SizedBox.expand(
                child: Image.asset(
                  splashImage,
                  fit: BoxFit.cover, // यह इमेज को बिना खींचे पूरी स्क्रीन पर फैला देगा
                ),
              ),

              // 2. मेटैलिक शाइन इफेक्ट (पूरी स्क्रीन के ऊपर एक चमक की लहर)
              AnimatedBuilder(
                animation: _shineAnimation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [
                          _shineAnimation.value - 0.5,
                          _shineAnimation.value,
                          _shineAnimation.value + 0.5,
                        ],
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3), // हल्की चमक की लहर
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcOver,
                    child: Container(color: Colors.transparent),
                  );
                },
              ),

              // 3. चमकता हुआ "V-Try" टेक्स्ट (सेंटर में नीचे की तरफ)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Text(
                    _displayedText,
                    style: TextStyle(
                      fontSize: isDesktop ? 60 : 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(blurRadius: 20, color: Colors.blueAccent.withValues(alpha: 0.8)),
                        Shadow(blurRadius: 40, color: Colors.white.withValues(alpha: 0.5)),
                      ],
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