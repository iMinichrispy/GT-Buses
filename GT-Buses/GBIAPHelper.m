//
//  GBIAPHelper.m
//  GT-Buses
//
//  Created by Alex Perez on 1/11/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

#import "GBIAPHelper.h"

@implementation GBIAPHelper

NSString *const NBIAPRemoveAdsIdentifier = @"com.alexperez.nextbusbuses.removeAds";

+ (GBIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static GBIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:NBIAPRemoveAdsIdentifier, nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
