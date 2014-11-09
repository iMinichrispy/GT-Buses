//
//  GBConfig.m
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConfig.h"

#if GTWIKI_API
static NSString * const GBConfigBaseURL = @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech";
static NSString * const GBConfigRouteConfigPath = @"&command=routeConfig";
static NSString * const GBConfigLocationsPath = @"&command=vehicleLocations&r=";
static NSString * const GBConfigPredictionsPath = @"&command=predictionsForMultiStops&r=";
static NSString * const GBConfigSchedulePath = @"";
static NSString * const GBConfigMessagesPath = @"&command=messages";
#else

#if !DEBUG || !TARGET_IPHONE_SIMULATOR
static NSString * const GBConfigBaseURL = @"https://gtbuses.herokuapp.com";
#else
static NSString * const GBConfigBaseURL = @"http://localhost:5000";
#endif

static NSString * const GBConfigRouteConfigPath = @"/routeConfig";
static NSString * const GBConfigLocationsPath = @"/locations/";
static NSString * const GBConfigPredictionsPath = @"/predictions/";
static NSString * const GBConfigSchedulePath = @"/schedule";
static NSString * const GBConfigMessagesPath = @"/messages";
#endif

@interface GBConfig ()

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *routeConfigPath;
@property (nonatomic, strong) NSString *locationsPath;
@property (nonatomic, strong) NSString *predictionsPath;
@property (nonatomic, strong) NSString *schedulePath;
@property (nonatomic, strong) NSString *messagesPath;

@end

@implementation GBConfig

+ (instancetype)sharedInstance {
    static GBConfig *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Check user defaults?
        _baseURL = GBConfigBaseURL;
        _routeConfigPath = GBConfigRouteConfigPath;
        _locationsPath = GBConfigLocationsPath;
        _predictionsPath = GBConfigPredictionsPath;
        _schedulePath = GBConfigSchedulePath;
        _messagesPath = GBConfigMessagesPath;
    }
    return self;
}

- (NSString *)routeConfigURL {
    return [_baseURL stringByAppendingString:_routeConfigPath];
}

- (NSString *)locationsBaseURL {
    return [_baseURL stringByAppendingString:_locationsPath];
}

- (NSString *)predictionsBaseURL {
    return [_baseURL stringByAppendingString:_predictionsPath];
}

- (NSString *)scheduleURL {
    return [_baseURL stringByAppendingString:_schedulePath];
}

- (NSString *)messagesURL {
    return [_baseURL stringByAppendingString:_messagesPath];
}

@end
