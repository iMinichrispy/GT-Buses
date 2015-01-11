//
//  NSUserDefaults+SharedDefaults.m
//  GT-Buses
//
//  Created by Alex Perez on 12/2/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "NSUserDefaults+SharedDefaults.h"

#import "GBConstants.h"

#warning need a way to set extensionsuite
#if NEXBUS_BUSES
static NSString *const GBSharedDefaultsExtensionSuiteName = @"group.com.alexperez.nextbus-buses";
#else
//static NSString *const GBSharedDefaultsExtensionSuiteName = @"group.com.alexperez.nextbus-buses";
static NSString *const GBSharedDefaultsExtensionSuiteName = @"group.com.alexperez.gt-buses";
#endif

@implementation NSUserDefaults (SharedDefaults)

+ (NSUserDefaults *)sharedDefaults {
    if ([NSUserDefaults instancesRespondToSelector:@selector(initWithSuiteName:)]) {
        return [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    }
    // Revert to standard defaults if device does not support shared defaults w/ extension
    return [NSUserDefaults standardUserDefaults];
}

@end
