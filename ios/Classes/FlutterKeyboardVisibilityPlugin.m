#import "FlutterKeyboardVisibilityPlugin.h"

@interface FlutterKeyboardVisibilityPlugin () <FlutterStreamHandler>

@property (copy, nonatomic) FlutterEventSink flutterEventSink;
@property (assign, nonatomic) BOOL flutterEventListening;
@property (assign, nonatomic) BOOL isVisible;

@end


@implementation FlutterKeyboardVisibilityPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterEventChannel *channel = [FlutterEventChannel
        eventChannelWithName:@"flutter_keyboard_visibility"
        binaryMessenger:[registrar messenger]];

    FlutterKeyboardVisibilityPlugin *instance =
        [[FlutterKeyboardVisibilityPlugin alloc] init];
    [channel setStreamHandler:instance];
}

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.isVisible = NO;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didShow)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(didHide)
                   name:UIKeyboardDidHideNotification
                 object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didShow {
    [self updateVisibility:YES];
}

- (void)didHide {
    [self updateVisibility:NO];
}

- (void)updateVisibility:(BOOL)visible {
    if (self.isVisible == visible) {
        return;
    }

    self.isVisible = visible;
    if (self.flutterEventListening && self.flutterEventSink != nil) {
        self.flutterEventSink(@(visible));
    }
}

- (FlutterError *)onListenWithArguments:(id)arguments
                              eventSink:(FlutterEventSink)events {
    self.flutterEventSink = events;
    self.flutterEventListening = YES;

    // If the keyboard is visible when the stream starts, report it once.
    if (self.isVisible) {
        self.flutterEventSink(@YES);
    }

    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    self.flutterEventListening = NO;
    self.flutterEventSink = nil;
    return nil;
}

@end
