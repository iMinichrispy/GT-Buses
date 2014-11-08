//
//  GBConstants.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConstants.h"

NSString * const GBFontDefault = @"Avenir-Medium";

NSString * const GBUserDefaultsFilePath = @"GBDefaultPreferences";
NSString * const GBUserDefaultsKeySelectedRoute = @"GBUserDefaultsKeySelectedRoute";
NSString * const GBUserDefaultsKeySelectedColor = @"GBUserDefaultsKeySelectedColor";

//NSString * const GBConfigBaseURL = @"https://gtbuses.herokuapp.com";
NSString * const GBConfigBaseURL = @"http://localhost:5000";
NSString * const GBConfigRouteConfigPath = @"/routeConfig";
NSString * const GBConfigLocationsPath = @"/locations/";
NSString * const GBConfigPredictionsPath = @"/predictions/";
NSString * const GBConfigMessagesPath = @"/messages";

NSString * const GBNotificationTintColorDidChange = @"GBNotificationTintColorDidChange";

float const kSideWidth = 150.0f;
float const kSideWidthiPad = 200.0f;
