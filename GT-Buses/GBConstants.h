//
//  GBConstants.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@class NSString;
extern NSString * const GBFontDefault;

extern NSString * const GBUserDefaultsAgencyKey;
extern NSString * const GBUserDefaultsSelectedRouteKey;
extern NSString * const GBUserDefaultsSelectedColorKey;

extern NSString * const GBSharedDefaultsExtensionSuiteName;
extern NSString * const GBSharedDefaultsFavoriteStopsKey;
extern NSString * const GBSharedDefaultsRoutesKey;

extern NSString * const GBNotificationTintColorDidChange;
extern NSString * const GBNotificationPartyModeDidChange;
extern NSString * const GBNotificationMessageDidChange;
extern NSString * const GBNotificationiOSVersionDidChange;

extern NSString * const GBRequestRouteConfigTask;
extern NSString * const GBRequestVehicleLocationsTask;
extern NSString * const GBRequestVehiclePredictionsTask;
extern NSString * const GBRequestMultiPredictionsTask;
extern NSString * const GBRequestMessagesTask;

extern float const kSideWidth;
extern float const kSideWidthiPad;

#define PARSE_ERROR_CODE    2923
#define NEXBUS_ERROR_CODE   2943

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define FORMAT(format,...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
