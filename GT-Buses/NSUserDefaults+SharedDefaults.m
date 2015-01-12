//
//  NSUserDefaults+SharedDefaults.m
//  GT-Buses
//
//  Created by Alex Perez on 12/2/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "NSUserDefaults+SharedDefaults.h"

#import "GBConstants.h"

@implementation NSUserDefaults (SharedDefaults)

+ (NSUserDefaults *)sharedDefaults {
    if ([NSUserDefaults instancesRespondToSelector:@selector(initWithSuiteName:)]) {
        return [[NSUserDefaults alloc] initWithSuiteName:[self sharedDefaultsSuiteName]];
    }
    // Revert to standard defaults if device does not support shared defaults w/ extension
    return [NSUserDefaults standardUserDefaults];
}

+ (NSString *)sharedDefaultsSuiteName {
    static NSString *suiteName;
    if (!suiteName) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleIdentifier = info[@"CFBundleIdentifier"];
        NSArray *components = [bundleIdentifier componentsSeparatedByString:@"."];
        if ([components count] == 4) {
            // Extensions will have an additional component on the bundle identifier, so remove it
            components = [components subarrayWithRange:NSMakeRange(0, 3)];
            bundleIdentifier = [components componentsJoinedByString:@"."];
        }
        suiteName = [NSString stringWithFormat:@"group.%@", bundleIdentifier];
    }
    return suiteName;
}

@end
