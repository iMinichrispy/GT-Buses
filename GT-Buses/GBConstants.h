//
//  GBConstants.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

extern NSString *const GBUserDefaultsFilePath;
extern NSString *const GBUserDefaultsKeyColor;
extern NSString *const GBUserDefaultsKeySelectedRoute;

extern NSString *const GBFontDefault;

extern NSString *const GBAppTintColorDidChangeNotification;


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)