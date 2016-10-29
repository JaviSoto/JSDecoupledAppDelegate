//
//  JSDecoupledAppDelegate.m
//
//  Created by Javier Soto on 9/9/13.
//  Copyright (c) 2013 JavierSoto. All rights reserved.
//

#import "JSDecoupledAppDelegate.h"

#import <objc/runtime.h>

static NSSet *_JSSelectorsInProtocol(Protocol *protocol, BOOL required)
{
    unsigned int methodCount;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, required, YES, &methodCount);

    NSMutableSet *selectorsInProtocol = [NSMutableSet setWithCapacity:methodCount];
    for (NSUInteger i = 0; i < methodCount; i++)
    {
        [selectorsInProtocol addObject:NSStringFromSelector(methods[i].name)];
    }

    free(methods);

    return selectorsInProtocol;
}

static NSSet *JSSelectorListInProtocol(Protocol *protocol)
{
    NSMutableSet *selectors = [NSMutableSet set];

    [selectors unionSet:_JSSelectorsInProtocol(protocol, YES)];
    [selectors unionSet:_JSSelectorsInProtocol(protocol, NO)];

    return selectors;
}

static NSArray *JSApplicationDelegateProperties()
{
    static NSArray *properties = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @[
                       NSStringFromSelector(@selector(appStateDelegate)),
                       NSStringFromSelector(@selector(appDefaultOrientationDelegate)),
                       NSStringFromSelector(@selector(backgroundFetchDelegate)),
                       NSStringFromSelector(@selector(remoteNotificationsDelegate)),
                       NSStringFromSelector(@selector(localNotificationsDelegate)),
                       NSStringFromSelector(@selector(stateRestorationDelegate)),
                       NSStringFromSelector(@selector(URLResourceOpeningDelegate)),
                       NSStringFromSelector(@selector(shortcutItemDelegate)),
                       NSStringFromSelector(@selector(healthDelegate)),
                       NSStringFromSelector(@selector(protectedDataDelegate)),
                       NSStringFromSelector(@selector(watchInteractionDelegate)),
                       NSStringFromSelector(@selector(extensionDelegate)),
                       NSStringFromSelector(@selector(activityContinuationDelegate)),
                       ];
    });

    return properties;
}

static NSArray *JSApplicationDelegateSubprotocols()
{
    static NSArray *protocols = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocols = @[
                      NSStringFromProtocol(@protocol(JSApplicationStateDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationDefaultOrientationDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationBackgroundFetchDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationRemoteNotificationsDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationLocalNotificationsDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationStateRestorationDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationURLResourceOpeningDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationShortcutItemDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationHealthDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationProtectedDataDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationWatchInteractionDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationExtensionDelegate)),
                      NSStringFromProtocol(@protocol(JSApplicationActivityContinuationDelegate)),
                      ];
    });

    return protocols;
}

@implementation JSDecoupledAppDelegate

#pragma mark - Method Proxying

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSArray *delegateProperties = JSApplicationDelegateProperties();

    // 1. Get the protocol that the method corresponds to
    __block BOOL protocolFound = NO;
    __block BOOL delegateRespondsToSelector = NO;

    [JSApplicationDelegateSubprotocols() enumerateObjectsUsingBlock:^(NSString *protocolName, NSUInteger idx, BOOL *stop) {
        NSSet *protocolMethods = JSSelectorListInProtocol(NSProtocolFromString(protocolName));

        const BOOL methodCorrespondsToThisProtocol = [protocolMethods containsObject:NSStringFromSelector(aSelector)];

        if (methodCorrespondsToThisProtocol)
        {
            protocolFound = YES;

            // 2. Get the property for that protocol
            id delegateObjectForProtocol = [self valueForKey:delegateProperties[idx]];

            delegateRespondsToSelector = [delegateObjectForProtocol respondsToSelector:aSelector];

            *stop = YES;
        }
    }];

    if (protocolFound)
    {
        // 3. Return whether that delegate responds to this method
        return delegateRespondsToSelector;
    }
    else
    {
        // 4. Doesn't correspond to any? Then just return whether we respond to it:
        return [super respondsToSelector:aSelector];
    }
}

#pragma mark - Singleton

static JSDecoupledAppDelegate *sharedAppDelegate = nil;

+ (void)initialize
{
    if (self == [JSDecoupledAppDelegate class])
    {
        sharedAppDelegate = [[self alloc] init];
    }
}

+ (JSDecoupledAppDelegate *)sharedAppDelegate
{
    return sharedAppDelegate;
}

- (id)init
{
    if (sharedAppDelegate)
    {
        self = nil;

        return sharedAppDelegate;
    }
    else
    {
        return [super init];
    }
}

#pragma mark - JSApplicationStateDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [self.appStateDelegate application:application willFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [self.appStateDelegate application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [self.appStateDelegate applicationDidFinishLaunching:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.appStateDelegate applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.appStateDelegate applicationDidBecomeActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.appStateDelegate applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.appStateDelegate applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.appStateDelegate applicationWillTerminate:application];
}

#pragma mark - JSApplicationDefaultOrientationDelegate

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return [self.appDefaultOrientationDelegate application:application supportedInterfaceOrientationsForWindow:window];
}

#pragma mark - JSApplicationBackgroundFetchDelegate

#if JSIOS7SDK
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [self.backgroundFetchDelegate application:application performFetchWithCompletionHandler:completionHandler];
}
#endif

#pragma mark - JSApplicationRemoteNotificationsDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.remoteNotificationsDelegate application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.remoteNotificationsDelegate application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.remoteNotificationsDelegate application:application didReceiveRemoteNotification:userInfo];
}

#if JSIOS7SDK
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [self.remoteNotificationsDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
#endif

#if JSIOS8SDK
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [self.remoteNotificationsDelegate application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0)
{
    [self.remoteNotificationsDelegate application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
}

#if JSIOS9SDK
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    [self.remoteNotificationsDelegate application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:completionHandler];
}
#endif


#endif

#pragma mark - JSApplicationLocalNotificationsDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.localNotificationsDelegate application:application didReceiveLocalNotification:notification];
}

#if JSIOS8SDK
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    [self.localNotificationsDelegate application:application handleActionWithIdentifier:identifier forLocalNotification:notification completionHandler:completionHandler];
}

#if JSIOS9SDK
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    [self.localNotificationsDelegate application:application handleActionWithIdentifier:identifier forLocalNotification:notification withResponseInfo:responseInfo completionHandler:completionHandler];
}
#endif

#endif


#pragma mark - JSApplicationStateRestorationDelegate

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [self.stateRestorationDelegate application:application viewControllerWithRestorationIdentifierPath:identifierComponents coder:coder];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return [self.stateRestorationDelegate application:application shouldSaveApplicationState:coder];
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return [self.stateRestorationDelegate application:application shouldRestoreApplicationState:coder];
}

- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    [self.stateRestorationDelegate application:application willEncodeRestorableStateWithCoder:coder];
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    [self.stateRestorationDelegate application:application didDecodeRestorableStateWithCoder:coder];
}

#pragma mark - JSApplicationURLResourceOpeningDelegate

#if JSIOS9SDK
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return [self.URLResourceOpeningDelegate application:app openURL:url options:options];
}
#elif JSIOS8SDK
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self.URLResourceOpeningDelegate application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
#else
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.URLResourceOpeningDelegate application:application handleOpenURL:url];
}
#endif

#pragma mark - JSApplicationShortcutItemDelegate

#if JSIOS9SDK
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler
{
	return [self.shortcutItemDelegate application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
}
#endif

#pragma mark - JSApplicationHealthDelegate

#if JSIOS9SDK
- (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application
{
	return [self.healthDelegate applicationShouldRequestHealthAuthorization:application];
}
#endif

#pragma mark - JSApplicationProtectedDataDelegate

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{
    [self.protectedDataDelegate applicationProtectedDataWillBecomeUnavailable:application];
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    [self.protectedDataDelegate applicationProtectedDataDidBecomeAvailable:application];
}

#pragma mark - JSApplicationWatchInteractionDelegate

#if JSIOS8_2SDK

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply
{
    [self.watchInteractionDelegate application:application handleWatchKitExtensionRequest:userInfo reply:reply];
}

#endif

#pragma mark - JSApplicationExtensionDelegate

#if JSIOS8SDK

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    return [self.extensionDelegate application:application shouldAllowExtensionPointIdentifier:extensionPointIdentifier];
}

#endif

#pragma mark - JSApplicationActivityContinuationDelegate

#if JSIOS8SDK

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType;
{
    return [self.activityContinuationDelegate application:application willContinueUserActivityWithType:userActivityType];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler;
{
    return [self.activityContinuationDelegate application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}
- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    [self.activityContinuationDelegate application:application didFailToContinueUserActivityWithType:userActivityType error:error];
}

- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity
{
    [self.activityContinuationDelegate application:application didUpdateUserActivity:userActivity];
}

#endif

@end
