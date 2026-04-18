import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF101325), Color(0xFF1B2147), Color(0xFF122C47)]
              : const [Color(0xFFF5F7FF), Color(0xFFECE9FF), Color(0xFFE5F4FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: _GlowBubble(
                color: const Color(0xFF8D80FF).withValues(alpha: 0.24),
              ),
            ),
            Positioned(
              right: -40,
              top: 120,
              child: _GlowBubble(
                size: 180,
                color: const Color(0xFF5CCCF6).withValues(alpha: 0.2),
              ),
            ),
            body,
          ],
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.color, this.size = 220});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 30),
          ],
        ),
      ),
    );
  }
}
