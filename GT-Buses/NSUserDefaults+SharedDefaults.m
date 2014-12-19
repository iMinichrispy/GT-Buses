//
//  NSUserDefaults+SharedDefaults.m
//  GT-Buses
//
//  Created by Alex Perez on 12/2/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "NSUserDefaults+SharedDefaults.h"

#import "GBConstants.h"

static NSString *const GBSharedDefaultsExtensionSuiteName = @"group.com.alexperez.gt-buses";

@implementation NSUserDefaults (SharedDefaults)

+ (NSUserDefaults *)sharedDefaults {
    if ([NSUserDefaults instancesRespondToSelector:@selector(initWithSuiteName:)]) {
        return [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    }
    return [NSUserDefaults standardUserDefaults];
}

@end
