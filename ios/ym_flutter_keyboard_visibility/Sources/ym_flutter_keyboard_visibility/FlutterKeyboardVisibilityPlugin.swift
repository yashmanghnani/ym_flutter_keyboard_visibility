#if os(iOS)
import Flutter
import UIKit

public final class FlutterKeyboardVisibilityPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var isVisible = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterEventChannel(
      name: "flutter_keyboard_visibility",
      binaryMessenger: registrar.messenger()
    )
    channel.setStreamHandler(FlutterKeyboardVisibilityPlugin())
  }

  public override init() {
    super.init()

    let center = NotificationCenter.default
    center.addObserver(
      self,
      selector: #selector(keyboardDidShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )
    center.addObserver(
      self,
      selector: #selector(keyboardDidHide),
      name: UIResponder.keyboardDidHideNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func keyboardDidShow() {
    updateVisibility(true)
  }

  @objc private func keyboardDidHide() {
    updateVisibility(false)
  }

  private func updateVisibility(_ visible: Bool) {
    guard isVisible != visible else { return }

    isVisible = visible
    eventSink?(visible)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    if isVisible {
      events(true)
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
#endif
