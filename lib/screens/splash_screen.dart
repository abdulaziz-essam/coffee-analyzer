import 'package:flutter/material.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _steamAnimation;
  late Animation<double> _cupAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _steamAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _cupAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Light cream background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated steam
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildSteamWave(0, -30),
                      _buildSteamWave(0.3, 0),
                      _buildSteamWave(0.6, 30),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Animated coffee cup with shadow
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: _cupAnimation.value,
                    child: _buildCoffeeCup(),
                  ),
                ),
                const SizedBox(height: 50),
                // Loading text with gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6F4E37), Color(0xFF3E2723)],
                  ).createShader(bounds),
                  child: const Text(
                    'Coffee CV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Brewing your experience...',
                  style: TextStyle(
                    color: const Color(0xFF6F4E37).withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSteamWave(double delay, double offset) {
    return Opacity(
      opacity: 0.7 - (_steamAnimation.value * 0.7),
      child: Transform.translate(
        offset: Offset(offset, -_steamAnimation.value * 100),
        child: Transform.scale(
          scale: 1 + (_steamAnimation.value * 0.8),
          child: Container(
            width: 12,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF8D6E63).withOpacity(0.6),
                  const Color(0xFF8D6E63).withOpacity(0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoffeeCup() {
    return Container(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: CoffeeCupPainter(),
      ),
    );
  }
}

class CoffeeCupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Cup shadow
    paint.color = Colors.black.withOpacity(0.05);
    final shadowPath = Path();
    shadowPath.moveTo(size.width * 0.28, size.height * 0.42);
    shadowPath.lineTo(size.width * 0.33, size.height * 0.82);
    shadowPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.87,
      size.width * 0.67, size.height * 0.82,
    );
    shadowPath.lineTo(size.width * 0.72, size.height * 0.42);
    shadowPath.close();
    canvas.drawPath(shadowPath, paint);

    // Cup body with gradient effect
    final cupRect = Rect.fromLTWH(
        size.width * 0.3, size.height * 0.4, size.width * 0.4, size.height * 0.4);
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFD7B28D),
        const Color(0xFFB8956A),
      ],
    ).createShader(cupRect);

    final cupPath = Path();
    cupPath.moveTo(size.width * 0.3, size.height * 0.4);
    cupPath.lineTo(size.width * 0.35, size.height * 0.8);
    cupPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.85,
      size.width * 0.65, size.height * 0.8,
    );
    cupPath.lineTo(size.width * 0.7, size.height * 0.4);
    cupPath.close();
    canvas.drawPath(cupPath, paint);

    // Cup rim highlight
    paint.shader = null;
    paint.color = const Color(0xFFE8D4B8);
    final rimPath = Path();
    rimPath.moveTo(size.width * 0.3, size.height * 0.4);
    rimPath.lineTo(size.width * 0.7, size.height * 0.4);
    rimPath.lineTo(size.width * 0.68, size.height * 0.42);
    rimPath.lineTo(size.width * 0.32, size.height * 0.42);
    rimPath.close();
    canvas.drawPath(rimPath, paint);

    // Coffee liquid with gradient
    final coffeeRect = Rect.fromLTWH(
        size.width * 0.32, size.height * 0.43, size.width * 0.36, size.height * 0.1);
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF4E342E),
        const Color(0xFF3E2723),
      ],
    ).createShader(coffeeRect);

    final coffeePath = Path();
    coffeePath.moveTo(size.width * 0.32, size.height * 0.43);
    coffeePath.lineTo(size.width * 0.68, size.height * 0.43);
    coffeePath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.48,
      size.width * 0.32, size.height * 0.43,
    );
    canvas.drawPath(coffeePath, paint);

    // Cup handle with gradient
    paint.shader = null;
    paint.color = const Color(0xFFB8956A);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10;
    paint.strokeCap = StrokeCap.round;
    final handlePath = Path();
    handlePath.moveTo(size.width * 0.7, size.height * 0.5);
    handlePath.quadraticBezierTo(
      size.width * 0.88, size.height * 0.5,
      size.width * 0.88, size.height * 0.67,
    );
    handlePath.quadraticBezierTo(
      size.width * 0.88, size.height * 0.72,
      size.width * 0.7, size.height * 0.72,
    );
    canvas.drawPath(handlePath, paint);

    // Handle inner shadow
    paint.strokeWidth = 6;
    paint.color = const Color(0xFFD7B28D);
    canvas.drawPath(handlePath, paint);

    // Heart in coffee (latte art) - improved
    paint.style = PaintingStyle.fill;
    paint.shader = null;
    paint.color = const Color(0xFFEFDECD);
    final heartPath = Path();
    final heartCenterX = size.width * 0.5;
    final heartCenterY = size.height * 0.44;
    heartPath.moveTo(heartCenterX, heartCenterY + 10);
    heartPath.cubicTo(
      heartCenterX - 15, heartCenterY,
      heartCenterX - 15, heartCenterY - 10,
      heartCenterX, heartCenterY - 6,
    );
    heartPath.cubicTo(
      heartCenterX + 15, heartCenterY - 10,
      heartCenterX + 15, heartCenterY,
      heartCenterX, heartCenterY + 10,
    );
    canvas.drawPath(heartPath, paint);

    // Coffee surface shine
    paint.color = Colors.white.withOpacity(0.1);
    final shinePath = Path();
    shinePath.moveTo(size.width * 0.35, size.height * 0.43);
    shinePath.lineTo(size.width * 0.45, size.height * 0.43);
    shinePath.quadraticBezierTo(
      size.width * 0.4, size.height * 0.44,
      size.width * 0.35, size.height * 0.43,
    );
    canvas.drawPath(shinePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
