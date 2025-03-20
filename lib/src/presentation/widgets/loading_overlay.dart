import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),

            child: Center(
              child: Lottie.asset(
                'assets/lottie/calendarioloading.json',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
