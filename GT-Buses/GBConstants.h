//
//  GBConstants.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

extern NSString * const GBFontDefault;

extern NSString * const GBUserDefaultsAgencyKey;
extern NSString * const GBUserDefaultsSelectedRouteKey;
extern NSString * const GBUserDefaultsSelectedColorKey;
extern NSString * const GBUserDefaultsBuildingsVersionKey;

extern NSString * const GBSharedDefaultsExtensionSuiteName;
extern NSString * const GBSharedDefaultsFavoriteStopsKey;
extern NSString * const GBSharedDefaultsRoutesKey;

extern NSString * const GBNotificationTintColorDidChange;
extern NSString * const GBNotificationPartyModeDidChange;
extern NSString * const GBNotificationMessageDidChange;
extern NSString * const GBNotificationiOSVersionDidChange;
extern NSString * const GBNotificationBuildingsVersionDidChange;

extern NSString * const GBRequestRouteConfigTask;
extern NSString * const GBRequestVehicleLocationsTask;
extern NSString * const GBRequestVehiclePredictionsTask;
extern NSString * const GBRequestMultiPredictionsTask;
extern NSString * const GBRequestMessagesTask;
extern NSString * const GBRequestBuildingsTask;

extern float const kSideWidth;
extern float const kSideWidthiPad;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE_6_PLUS ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) >= 736)
#define ROTATION_ENABLED (IS_IPAD || IS_IPHONE_6_PLUS)

#define FORMAT(format,...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
