JSDecoupledAppDelegate
======================

`UIApplicationDelegate` class that separates the different responsibilities into more more reusable classes.

### Motivation
`UIApplicationDelegate` is perhaps the most convoluted protocol in UIKit. A class that conforms to it won't have one single responsibility, hence it violates one of the most important OOP principles: the **Single Responsibility Principle** ([SRP](http://en.wikipedia.org/wiki/Single_responsibility_principle))

The consequence of this is that all the code that we throw in it becomes essentially non-reusable. Our **App Delegate** becomes often times the **most coupled class to your application**, and none of the code we write there is easily reusable in another application. However, a lot of the code that we write there should be reusable: handling notifications, state restoration, opening URLs... Ideally we should **extract each of these responsibilities into their own class**. This is exactly what **`JSDecoupledAppDelegate`** allows you to do.

### Protocols
`JSDecoupledAppDelegate` exposes a series of different protocols that each of the classes that will implement one of the responsibilities will conform to:

```objc
@protocol JSApplicationStateDelegate;
@protocol JSApplicationDefaultOrientationDelegate;
@protocol JSApplicationBackgroundFetchDelegate;
@protocol JSApplicationRemoteNotificationsDelegate;
@protocol JSApplicationLocalNotificationsDelegate;
@protocol JSApplicationStateRestorationDelegate;
@protocol JSApplicationURLResourceOpeningDelegate;
@protocol JSApplicationProtectedDataDelegate;
```

`JSDecoupledAppDelegate` has one property for each of these protocols that you have to set with the object that conforms to it.
**All of the protocols are optional**, meaning that you don't have to provide an object unless you want to implement one of the methods.

Check `JSDecoupledAppDelegate.h` for more details on what methods each of the protocols has.

**NOTE**:
Some of the protocol methods are missing because they're not necessary: whenever there's a corresponding `NSNotification` that gets sent (specially if the method doesn't have to return anything), it's a better practice to listen for that instead of implementing the method. This allows you to listen to the notification in multiple places vs. implementing all of the logic related to that event in the same method, hence helping you keep responsibilities separate.

### Usage
First you must tell `UIApplication` that it should instantiate an instance of the `JSDecoupledAppDelegate` class. This happens on the `int main()` method normally on the `main.m` file:

```objc
return UIApplicationMain(argc, argv, nil, NSStringFromClass([JSDecoupledAppDelegate class]));
```

After this, all you have to do is to get the instance of the App Delegate and start setting some of its properties.

The only caveat when using `JSDecoupledAppDelegate` is making sure that you set some of the delegate properties before one of the methods is going to be invoked (e.g. `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;`)

One way of doing this is to implement `+load` on one of the classes that implements a `JSDecoupledAppDelegate` delegate protocols and doing something similar to this:

```objc
+ (void)load
{
    [JSDecoupledAppDelegate sharedAppDelegate].appStateDelegate = [[self alloc] init];
}
```

This is why `JSDecoupledAppDelegate` provides a `-sharedAppDelegate` method which returns the **singleton** instance of it. This is to make sure that if this gets called before `UIApplication` creates the App Delegate, not two instances are created. Also because it doesn't make sense for an application to have more than one App Delegate object.

For more details on this, check the Sample Application in this repo.

### Installation

- Using [CocoaPods](http://cocoapods.org/):

Just add this line to your `Podfile`:

```
pod 'JSDecoupledAppDelegate', '~> 1.0.0'
```

- Manually:

Simply add the files `JSDecoupledAppDelegate.h` and `JSDecoupledAppDelegate.m` to your project.

### Compatibility
`JSDecoupledAppDelegate` is compatible with iOS 5, iOS 6, iOS 7 and iOS 8.

### License
`JSDecoupledAppDelegate` is available under the MIT license. See the LICENSE file for more info.
