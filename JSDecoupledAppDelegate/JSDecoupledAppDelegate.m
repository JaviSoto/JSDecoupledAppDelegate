//
//  JSDecoupledAppDelegate.m
//
//  Created by Javier Soto on 9/9/13.
//  Copyright (c) 2013 JavierSoto. All rights reserved.
//

#import "JSDecoupledAppDelegate.h"

#import <objc/runtime.h>

static void JSRemoveAllOccurrencesOfObjectFromDictionaryRef(id object, CFMutableDictionaryRef dictionary);
static void JSAddMethodsFromProtocolImplementedByObjectToDictionaryRef(Protocol *protocol, id object, CFMutableDictionaryRef dictionary);

@implementation JSDecoupledAppDelegate
{
	CFMutableDictionaryRef _delegatesBySelector;
}

#pragma mark - Method Proxying

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if ([self forwardingTargetForSelector:aSelector]) return YES;

	return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
	id target = (id)CFDictionaryGetValue(_delegatesBySelector, selector);
	if (target)
		return target;

	return [super forwardingTargetForSelector:selector];
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

- (void)dealloc
{
	if (_delegatesBySelector)
		CFRelease(_delegatesBySelector);
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

