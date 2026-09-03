import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ym_flutter_keyboard_visibility/src/keyboard_visibility_controller.dart';

/// Widget that reports to its descendants whether or not
/// the keyboard is currently visible.
///
/// Example usage:
///
/// ```
/// // A Builder is used in this example solely for the purpose
/// // of demonstrating ancestor access from within a single
/// // build() method. You do not need to use a Builder if you
/// // access KeyboardVisibilityProvider from within a custom
/// // StatelessWidget or StatefulWidget.
/// return KeyboardVisibilityProvider(
///   child: Builder(
///     builder: (BuildContext context) {
///       final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
///
///       return Text('Keyboard is visible: $isKeyboardVisible');
///     },
///   ),
/// );
/// ```
class KeyboardVisibilityProvider extends StatefulWidget {
  final Widget child;

  /// Optional: pass in a controller you already have created. This is useful
  /// for testing, as you can pass in a mock instance. If no controller is
  /// passed in, one will be created automatically.
  final KeyboardVisibilityController? controller;

  KeyboardVisibilityController get _controller =>
      controller ?? KeyboardVisibilityController();

  const KeyboardVisibilityProvider({
    super.key,
    required this.child,
    this.controller,
  });

  /// Returns `true` if the keyboard is currently visible, `false`
  /// if the keyboard is not currently visible, or `null` if
  /// the `flutter_keyboard_visibility` plugin does not yet
  /// know if the keyboard is visible.
  ///
  /// This method also establishes an `InheritedWidget` dependency
  /// with the given `context`, and therefore the given `context`
  /// will automatically rebuild if the keyboard visibility changes.
  static bool isKeyboardVisible(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          _KeyboardVisibilityInheritedWidget
        >()!
        .isKeyboardVisible;
  }

  @override
  State<KeyboardVisibilityProvider> createState() =>
      _KeyboardVisibilityProviderState();
}

class _KeyboardVisibilityProviderState
    extends State<KeyboardVisibilityProvider> {
  StreamSubscription<bool>? _subscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _subscribe(widget._controller);
  }

  @override
  void didUpdateWidget(covariant KeyboardVisibilityProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._controller != widget._controller) {
      _subscribe(widget._controller);
    }
  }

  void _subscribe(KeyboardVisibilityController controller) {
    _subscription?.cancel();
    _isKeyboardVisible = controller.isVisible;
    _subscription = controller.onChange.listen(_onKeyboardVisibilityChange);
  }

  void _onKeyboardVisibilityChange(bool isKeyboardVisible) {
    if (!mounted || _isKeyboardVisible == isKeyboardVisible) {
      return;
    }
    setState(() => _isKeyboardVisible = isKeyboardVisible);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KeyboardVisibilityInheritedWidget(
      isKeyboardVisible: _isKeyboardVisible,
      child: widget.child,
    );
  }
}

/// `InheritedWidget` that rebuilds descendants whenever
/// `isKeyboardVisible` changes.
class _KeyboardVisibilityInheritedWidget extends InheritedWidget {
  const _KeyboardVisibilityInheritedWidget({
    required this.isKeyboardVisible,
    required super.child,
  });

  final bool isKeyboardVisible;

  @override
  bool updateShouldNotify(_KeyboardVisibilityInheritedWidget oldWidget) {
    return isKeyboardVisible != oldWidget.isKeyboardVisible;
  }
}
