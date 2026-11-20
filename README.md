# YM Flutter Keyboard Visibility

[![pub package](https://img.shields.io/pub/v/ym_flutter_keyboard_visibility.svg)](https://pub.dev/packages/ym_flutter_keyboard_visibility)

Observe soft-keyboard visibility changes and dismiss the keyboard from Flutter
on Android and iOS.

## Requirements

- Flutter 3.47.0 or newer
- Dart 3.13.2 or newer
- Android API 24 or newer
- iOS 15.0 or newer

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  ym_flutter_keyboard_visibility: ^1.1.1
```

Then run `flutter pub get`.

## Observe visibility

### Builder

Use `KeyboardVisibilityBuilder` when only part of the widget tree depends on
visibility:

```dart
import 'package:flutter/widgets.dart';
import 'package:ym_flutter_keyboard_visibility/ym_flutter_keyboard_visibility.dart';

class KeyboardStatus extends StatelessWidget {
  const KeyboardStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Text(isKeyboardVisible ? 'Keyboard visible' : 'Keyboard hidden');
      },
    );
  }
}
```

### Provider

Use `KeyboardVisibilityProvider` when multiple descendants need the same
value:

```dart
return KeyboardVisibilityProvider(
  child: Builder(
    builder: (context) {
      final visible = KeyboardVisibilityProvider.isKeyboardVisible(context);
      return Text(visible ? 'Keyboard visible' : 'Keyboard hidden');
    },
  ),
);
```

The lookup establishes an inherited-widget dependency, so the descendant is
rebuilt only when the boolean value changes.

### Direct query and stream

`KeyboardVisibilityController` is a singleton and can be used outside the
widget tree:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';

final controller = KeyboardVisibilityController();
final currentlyVisible = controller.isVisible;
final StreamSubscription<bool> subscription = controller.onChange.listen(
  (visible) => debugPrint('Keyboard visible: $visible'),
);

// Cancel the subscription when the owning object is disposed.
await subscription.cancel();
```

The stream emits only when the state changes. The initial state is `false`
until the host platform reports otherwise.

## Dismiss on tap

Wrap a page or subtree with `KeyboardDismissOnTap`:

```dart
return KeyboardDismissOnTap(
  child: const MyPage(),
);
```

By default, taps handled by interactive descendants are left alone. Set
`dismissOnCapturedTaps: true` to dismiss for every pointer-up event:

```dart
return KeyboardDismissOnTap(
  dismissOnCapturedTaps: true,
  child: const MyPage(),
);
```

Use `IgnoreKeyboardDismiss` around a subtree that should never dismiss the
keyboard.

## Testing

Inject a `KeyboardVisibilityController` into `KeyboardVisibilityBuilder` or
`KeyboardVisibilityProvider` to use a mock or a test double. For widget tests
that need a deterministic global value:

```dart
KeyboardVisibilityTesting.setVisibilityForTesting(true);
// Run the test assertions.
KeyboardVisibilityTesting.clearVisibilityForTesting();
```

Always clear the override in test teardown when the test suite contains other
keyboard visibility tests.

## Platform implementation

The package uses one `EventChannel` named `flutter_keyboard_visibility`.
Android observes global layout changes and iOS observes keyboard show/hide
notifications. Native listeners are detached during activity/engine
lifecycles, and duplicate visibility values are filtered before reaching Dart.
On iOS, both CocoaPods and Swift Package Manager integration are included.

## License

See [LICENSE](LICENSE).
