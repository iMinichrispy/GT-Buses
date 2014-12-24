//
//  UIDevice+Hardware.m
//  GT-Buses
//
//  Created by Alex Perez on 11/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "UIDevice+Hardware.h"

#import "GBConstants.h"
#import <sys/utsname.h>

@implementation UIDevice (Hardware)

- (BOOL)supportsVisualEffects {
#if TARGET_IPHONE_SIMULATOR
    // Checking via machine name doesn't work on simulator, so just assume yes for all devices
    return YES;
#else
    if (NSClassFromString(@"UIVisualEffectView")) {
        if (UIAccessibilityIsReduceTransparencyEnabled()) {
            return NO;
        }
        
        NSString *machineName = [self machineName];
        
        // iPad 2 and iPad 3 (AKA iPad w/ Retina Display) are the only >=iOS 8 devices that don't support blurring
        NSArray *incompatibleDevices = @[@"iPad2,1", @"iPad2,2", @"iPad2,3", @"iPad2,4", @"iPad3,1", @"iPad3,2", @"iPad3,3"];
        if ([incompatibleDevices containsObject:machineName]) {
            return NO;
        }
        return YES;
    }
    return NO;
#endif
}

- (NSString *)machineName {
    static NSString *machineName;
    if (!machineName) {
        struct utsname systemInfo;
        uname(&systemInfo);
        machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    }
    return machineName;
}

@end
