//
//  JSDecoupledAppDelegate.h
//
//  Created by Javier Soto on 9/9/13.
//  Copyright (c) 2013 JavierSoto. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JSSDKAtLeastIOS7 (__IPHONE_OS_VERSION_MAX_ALLOWED >= 70000)
#define JSSDKAtLeastIOS8 (__IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
#define JSSDKAtLeastIOS8_2 (__IPHONE_OS_VERSION_MAX_ALLOWED >= 80200)
#define JSSDKAtLeastIOS9 (__IPHONE_OS_VERSION_MAX_ALLOWED >= 90000)
#define JSSDKAtLeastIOS10 (__IPHONE_OS_VERSION_MAX_ALLOWED >= 100000)
#if !__has_feature(nullability)
    #define _Nonnull
    #define _Nullable
    #define nullable
    #define NS_ASSUME_NONNULL_BEGIN
    #define NS_ASSUME_NONNULL_END
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol JSApplicationStateDelegate;
@protocol JSApplicationDefaultOrientationDelegate;
@protocol JSApplicationBackgroundFetchDelegate;
@protocol JSApplicationRemoteNotificationsDelegate;
@protocol JSApplicationLocalNotificationsDelegate;
@protocol JSApplicationStateRestorationDelegate;
@protocol JSApplicationURLResourceOpeningDelegate;
@protocol JSApplicationShortcutItemDelegate;
@protocol JSApplicationHealthDelegate;
@protocol JSApplicationProtectedDataDelegate;
@protocol JSApplicationWatchInteractionDelegate;
@protocol JSApplicationExtensionDelegate;
@protocol JSApplicationActivityContinuationDelegate;

@interface JSDecoupledAppDelegate : UIResponder <UIApplicationDelegate>

/**
 * This returns the unique instance of the app delegate.
 * @discussion you must use this method from the `+load` method of your delegate classes if you want to set the delegate property before the app is initialized.
 * This ensures that your delegate is set up and ready to be queried before `UIApplication` starts asking questions.
 */
+ (JSDecoupledAppDelegate *)sharedAppDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, nullable) id<JSApplicationStateDelegate> appStateDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationDefaultOrientationDelegate> appDefaultOrientationDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationBackgroundFetchDelegate> backgroundFetchDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationRemoteNotificationsDelegate> remoteNotificationsDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationLocalNotificationsDelegate> localNotificationsDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationStateRestorationDelegate> stateRestorationDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationURLResourceOpeningDelegate> URLResourceOpeningDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationShortcutItemDelegate> shortcutItemDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationHealthDelegate> healthDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationProtectedDataDelegate> protectedDataDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationWatchInteractionDelegate> watchInteractionDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationExtensionDelegate> extensionDelegate;
@property (strong, nonatomic, nullable) id<JSApplicationActivityContinuationDelegate> activityContinuationDelegate;

@end

#pragma mark - Protocol Definitions

@protocol JSApplicationStateDelegate <NSObject>

@optional
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

// These events are also available in the form of NSNotifications.
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidFinishLaunching:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

@end

@protocol JSApplicationDefaultOrientationDelegate <NSObject>

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

@end

@protocol JSApplicationBackgroundFetchDelegate <NSObject>


#if JSSDKAtLeastIOS7
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
#endif

@end

@protocol JSApplicationRemoteNotificationsDelegate <NSObject>

@optional
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#if JSSDKAtLeastIOS7
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
#endif

#if JSSDKAtLeastIOS10 && ! JSSDKAtLeastIOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0);
#endif

#if JSSDKAtLeastIOS9
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(9_0);
#endif

@end

@protocol JSApplicationLocalNotificationsDelegate <NSObject>

#if JSSDKAtLeastIOS10 && ! JSSDKAtLeastIOS8
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler;
#endif

#if JSSDKAtLeastIOS10 && ! JSSDKAtLeastIOS9
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(9_0);
#endif

@end

@protocol JSApplicationStateRestorationDelegate <NSObject>

@optional
- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder;
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder;
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder;
- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder;
- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder;

@end

@protocol JSApplicationURLResourceOpeningDelegate <NSObject>

#if JSSDKAtLeastIOS9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;
#elif JSSDKAtLeastIOS8
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;
#else
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
#endif

@end

@protocol JSApplicationShortcutItemDelegate <NSObject>

#if JSSDKAtLeastIOS9
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler NS_AVAILABLE_IOS(9_0);
#endif

@end

@protocol JSApplicationHealthDelegate <NSObject>

#if JSSDKAtLeastIOS9
- (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_AVAILABLE_IOS(9_0);
#endif

@end

@protocol JSApplicationProtectedDataDelegate <NSObject>

@optional
- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application;
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application;

@end

@protocol JSApplicationWatchInteractionDelegate <NSObject>
#if JSSDKAtLeastIOS8_2
@optional
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)( NSDictionary * _Nullable replyInfo))reply;
#endif
@end

@protocol JSApplicationExtensionDelegate <NSObject>
#if JSSDKAtLeastIOS8
@optional
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier NS_AVAILABLE_IOS(8_0);
#endif
@end

@protocol JSApplicationActivityContinuationDelegate <NSObject>
#if JSSDKAtLeastIOS8
@optional
- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType NS_AVAILABLE_IOS(8_0);
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * _Nullable restorableObjects))restorationHandler NS_AVAILABLE_IOS(8_0);
- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error NS_AVAILABLE_IOS(8_0);
- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity NS_AVAILABLE_IOS(8_0);
#endif

@end

NS_ASSUME_NONNULL_END
