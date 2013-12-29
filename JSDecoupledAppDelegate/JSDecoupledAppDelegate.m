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
    NSUInteger methodCount;
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
                       NSStringFromSelector(@selector(protectedDataDelegate)),
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
                      NSStringFromProtocol(@protocol(JSApplicationProtectedDataDelegate))
                      ];
    });

    return protocols;
}

@implementation JSDecoupledAppDelegate
{
	CFMutableDictionaryRef _delegatesBySelector;
}

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
		self = [super init];
		if (self)
		{
			_delegatesBySelector = CFDictionaryCreateMutable(kCFAllocatorDefault, 60, NULL, &kCFTypeDictionaryValueCallBacks);
		}
        return self;
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

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
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

#pragma mark - JSApplicationLocalNotificationsDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.localNotificationsDelegate application:application didReceiveLocalNotification:notification];
}

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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self.URLResourceOpeningDelegate application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - JSApplicationProtectedDataDelegate

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{
    [self.protectedDataDelegate applicationProtectedDataWillBecomeUnavailable:application];
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    [self.protectedDataDelegate applicationProtectedDataDidBecomeAvailable:application];
}

@end

#pragma mark - Helper Functions
/*
 Note: This helper only exists, because the class is mutable.
 If all the properties were readonly, there would be no cache to invalidate...
 */
static void JSRemoveAllOccurrencesOfObjectFromDictionaryRef(id object, CFMutableDictionaryRef dictionary)
{
	if (!object) return;

	SEL *allKeys = calloc(CFDictionaryGetCount(dictionary) + 1, sizeof(SEL));
	CFDictionaryGetKeysAndValues(dictionary, (const void **)allKeys, NULL);
	for (SEL *keyPointer = allKeys, key; (key = *keyPointer); keyPointer++)
	{
		if (object == (id)CFDictionaryGetValue(dictionary, key))
			CFDictionaryRemoveValue(dictionary, key);
	}
	free(allKeys);
}

static void JSAddMethodsFromProtocolImplementedByObjectToDictionaryRef(Protocol *protocol, id object, CFMutableDictionaryRef dictionary)
{
	if (!object) return;

	void (^setObjectForImplementedSelectors)(struct objc_method_description *, unsigned int) = ^(struct objc_method_description *methods, unsigned int methodCount){
		for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++)
		{
			SEL methodName = methods[methodIndex].name;
			if (![object respondsToSelector:methodName]) continue;

			CFDictionarySetValue(dictionary, methodName, (__bridge void *)object);
		}
	};

	unsigned int methodCount;
	struct objc_method_description *instanceMethods = protocol_copyMethodDescriptionList(protocol, YES, YES, &methodCount);
	setObjectForImplementedSelectors(instanceMethods, methodCount);
	free(instanceMethods);

	instanceMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
	setObjectForImplementedSelectors(instanceMethods, methodCount);
	free(instanceMethods);
}

