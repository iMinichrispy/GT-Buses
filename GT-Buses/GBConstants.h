//
//  GBConstants.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

#import "NSUserDefaults+SharedDefaults.h"

extern NSString *const GBFontDefault;

extern NSString *const GBUserDefaultsSelectedRouteKey;
extern NSString *const GBUserDefaultsSelectedColorKey;
extern NSString *const GBUserDefaultsBuildingsFileNamesKey;
extern NSString *const GBUserDefaultsShowsBusIdentifiersKey;
extern NSString *const GBUserDefaultsAgenciesKey;

extern NSString *const GBSharedDefaultsAgencyKey;
extern NSString *const GBSharedDefaultsFavoriteStopsKey;
extern NSString *const GBSharedDefaultsRoutesKey;
extern NSString *const GBSharedDefaultsDisabledRoutesKey;
extern NSString *const GBSharedDefaultsShowsArrivalTimeKey;

extern NSString *const GBNotificationTintColorDidChange;
extern NSString *const GBNotificationPartyModeDidChange;
extern NSString *const GBNotificationMessageDidChange;
extern NSString *const GBNotificationiOSVersionDidChange;
extern NSString *const GBNotificationShowsBusIdentifiersDidChange;
extern NSString *const GBNotificationDisabledRoutesDidChange;
extern NSString *const GBNotificationAgencyDidChange;
extern NSString *const GBNotificationAdsVisibleDidChange;
extern NSString *const GBNotificationRoutesDidChange;

extern NSString *const NBIAPRemoveAdsIdentifier;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE_6_PLUS ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) >= 736)
#define ROTATION_ENABLED (IS_IPAD || IS_IPHONE_6_PLUS)

#define FORMAT(format,...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
