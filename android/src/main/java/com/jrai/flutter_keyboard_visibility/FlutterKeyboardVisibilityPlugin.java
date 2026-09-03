package com.jrai.flutter_keyboard_visibility;

import android.app.Activity;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;


public class FlutterKeyboardVisibilityPlugin implements FlutterPlugin, ActivityAware,
    EventChannel.StreamHandler, ViewTreeObserver.OnGlobalLayoutListener {
  private static final String CHANNEL_NAME = "flutter_keyboard_visibility";

  private EventChannel eventChannel;
  private EventChannel.EventSink eventSink;
  private View mainView;
  private final Rect visibleFrame = new Rect();
  private boolean isVisible = false;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    eventChannel = new EventChannel(
        flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    unregisterListener();
    eventSink = null;
    if (eventChannel != null) {
      eventChannel.setStreamHandler(null);
      eventChannel = null;
    }
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    listenForKeyboard(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    unregisterListener();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    listenForKeyboard(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    unregisterListener();
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink eventSink) {
    this.eventSink = eventSink;
    eventSink.success(isVisible ? 1 : 0);
  }

  @Override
  public void onCancel(Object arguments) {
    this.eventSink = null;
  }

  @Override
  public void onGlobalLayout() {
    if (mainView == null) {
      return;
    }

    final View rootView = mainView.getRootView();
    if (rootView == null || rootView.getHeight() <= 0) {
      return;
    }

    mainView.getWindowVisibleDisplayFrame(visibleFrame);

    // If the visible part of the screen is less than 85%, the keyboard is
    // considered visible. Reuse the Rect to avoid an allocation per layout.
    final boolean newState = ((double) visibleFrame.height()
        / (double) rootView.getHeight()) < 0.85;

    if (newState != isVisible) {
      isVisible = newState;
      if (eventSink != null) {
        eventSink.success(isVisible ? 1 : 0);
      }
    }
  }

  private void listenForKeyboard(Activity activity) {
    unregisterListener();
    mainView = activity.findViewById(android.R.id.content);
    if (mainView == null) {
      return;
    }
    mainView.getViewTreeObserver().addOnGlobalLayoutListener(this);
    onGlobalLayout();
  }

  private void unregisterListener() {
    if (mainView != null) {
      mainView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
      mainView = null;
    }
  }
}
