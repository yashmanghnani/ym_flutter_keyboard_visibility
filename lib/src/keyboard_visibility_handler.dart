import 'dart:async';

import 'package:flutter/services.dart';

/// Provides access to the current keyboard visibility state and emits
/// changes as they happen. For internal use only.
class KeyboardVisibilityHandler {
  KeyboardVisibilityHandler._();

  static const EventChannel _eventChannel = EventChannel(
    'flutter_keyboard_visibility',
  );

  static bool _isInitialized = false;
  static StreamSubscription<dynamic>? _platformSubscription;
  static final StreamController<bool> _onChangeController =
      StreamController<bool>.broadcast(
        onListen: _ensureInitialized,
        onCancel: _cancelPlatformSubscription,
      );

  /// Emits true every time the keyboard is shown, and false every time the
  /// keyboard is dismissed.
  static Stream<bool> get onChange => _onChangeController.stream;

  /// Returns true if the keyboard is currently visible, false if not.
  static bool get isVisible => _testIsVisible ?? _isVisible;
  static bool _isVisible = false;

  /// Fake representation of whether or not the keyboard is visible
  /// for testing purposes. When this value is non-null, it will be
  /// reported exclusively by the `isVisible` getter.
  static bool? _testIsVisible;

  /// Forces `KeyboardVisibilityHandler` to report `isKeyboardVisible`
  /// for testing purposes.
  ///
  /// `KeyboardVisibilityHandler` will continue reporting `isKeyboardVisible`
  /// until the value is changed again with this method.
  static void setVisibilityForTesting(bool isKeyboardVisible) {
    _testIsVisible = isKeyboardVisible;
    _updateValue(isKeyboardVisible);
  }

  /// Removes the test override and resumes reporting the native value.
  static void clearVisibilityForTesting() {
    _testIsVisible = null;
  }

  static void _ensureInitialized() {
    if (_isInitialized ||
        _platformSubscription != null ||
        _testIsVisible != null) {
      return;
    }

    _isInitialized = true;
    _platformSubscription = _eventChannel.receiveBroadcastStream().listen(
      _updateFromPlatform,
      // A host application may not register the plugin on every platform.
      // Keep the public stream usable and retain the default hidden state.
      onError: _ignorePlatformError,
    );
  }

  static Future<void> _cancelPlatformSubscription() async {
    _isInitialized = false;
    final subscription = _platformSubscription;
    _platformSubscription = null;
    await subscription?.cancel();
  }

  static void _ignorePlatformError(Object error, StackTrace stackTrace) {}

  static void _updateFromPlatform(dynamic value) {
    if (_testIsVisible != null) {
      return;
    }

    final bool? visible = switch (value) {
      bool value => value,
      num value when value == 1 => true,
      num value when value == 0 => false,
      _ => null,
    };

    if (visible != null) {
      _updateValue(visible);
    }
  }

  static void _updateValue(bool newValue) {
    // Don't report the same value multiple times
    if (newValue == _isVisible) {
      return;
    }

    _isVisible = newValue;
    _onChangeController.add(newValue);
  }
}
