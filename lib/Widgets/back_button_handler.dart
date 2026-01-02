import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A utility widget that handles back button behavior consistently across the app.
/// It provides a fallback for older Flutter versions by using WillPopScope when PopScope is not available.
class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final Future<bool> Function()? onWillPop;
  final bool canPop;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.onWillPop,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    // Try to use PopScope first (Flutter 3.12+)
    try {
      return PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop && onWillPop != null) {
            final shouldPop = await onWillPop!();
            if (shouldPop) {
              SystemNavigator.pop();
            }
          }
        },
        child: child,
      );
    } catch (e) {
      // Fallback to WillPopScope for older Flutter versions
      // ignore: deprecated_member_use
      return WillPopScope(
        onWillPop: onWillPop ?? () async => canPop,
        child: child,
      );
    }
  }
}