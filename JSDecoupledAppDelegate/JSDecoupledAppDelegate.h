//
//  JSDecoupledAppDelegate.h
//
//  Created by Javier Soto on 9/9/13.
//  Copyright (c) 2013 JavierSoto. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JSIOS7SDK (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0)
#define JSIOS8SDK (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0)
#define JSIOS8_2SDK (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_2)

@protocol JSApplicationStateDelegate;
@protocol JSApplicationDefaultOrientationDelegate;
@protocol JSApplicationBackgroundFetchDelegate;
@protocol JSApplicationRemoteNotificationsDelegate;
@protocol JSApplicationLocalNotificationsDelegate;
@protocol JSApplicationStateRestorationDelegate;
@protocol JSApplicationURLResourceOpeningDelegate;
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

@property (strong, nonatomic) id<JSApplicationStateDelegate> appStateDelegate;
@property (strong, nonatomic) id<JSApplicationDefaultOrientationDelegate> appDefaultOrientationDelegate;
@property (strong, nonatomic) id<JSApplicationBackgroundFetchDelegate> backgroundFetchDelegate;
@property (strong, nonatomic) id<JSApplicationRemoteNotificationsDelegate> remoteNotificationsDelegate;
@property (strong, nonatomic) id<JSApplicationLocalNotificationsDelegate> localNotificationsDelegate;
@property (strong, nonatomic) id<JSApplicationStateRestorationDelegate> stateRestorationDelegate;
@property (strong, nonatomic) id<JSApplicationURLResourceOpeningDelegate> URLResourceOpeningDelegate;
@property (strong, nonatomic) id<JSApplicationProtectedDataDelegate> protectedDataDelegate;
@property (strong, nonatomic) id<JSApplicationWatchInteractionDelegate> watchInteractionDelegate;
@property (strong, nonatomic) id<JSApplicationExtensionDelegate> extensionDelegate;
@property (strong, nonatomic) id<JSApplicationActivityContinuationDelegate> activityContinuationDelegate;

@end

#pragma mark - Protocol Definitions

@protocol JSApplicationStateDelegate <NSObject>

@optional
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

// These events are also available in the form of NSNotifications.
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidFinishLaunching:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

@end

@protocol JSApplicationDefaultOrientationDelegate <NSObject>

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;

@end

@protocol JSApplicationBackgroundFetchDelegate <NSObject>

#if JSIOS7SDK
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
#endif

@end

@protocol JSApplicationRemoteNotificationsDelegate <NSObject>

@optional
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#if JSIOS7SDK
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
#endif

#if JSIOS8SDK
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0);
#endif

@end

@protocol JSApplicationLocalNotificationsDelegate <NSObject>

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

#if JSIOS8SDK
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler;
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end

@protocol JSApplicationProtectedDataDelegate <NSObject>

@optional
- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application;
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application;

@end

@protocol JSApplicationWatchInteractionDelegate <NSObject>
#if JSIOS8_2SDK
@optional
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply;
#endif
@end

@protocol JSApplicationExtensionDelegate <NSObject>
#if JSIOS8SDK
@optional
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier;
#endif
@end

@protocol JSApplicationActivityContinuationDelegate <NSObject>
#if JSIOS8SDK
@optional
- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType;
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler;
- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error;
- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity;
#endif

@end
