//
//  GBRequestHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestHandler.h"

#import "GBConstants.h"
#import "GBConfig.h"

#if LOCAL_SERVER
static NSString * const GBRequestBaseURL = @"http://localhost:5000";
#else
static NSString * const GBRequestBaseURL = @"https://gtbuses.herokuapp.com";
#endif

// public xml feed:
// http://webservices.nextbus.com/service/publicXMLFeed?command=agencyList
// http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=mit

NSString * const GBRequestErrorDomain = @"com.alexperez.gtbuses.requestErrors";

static NSString * const GBRequestRouteConfigPath = @"/routeConfig";
static NSString * const GBRequestLocationsPath = @"/locations/";
static NSString * const GBRequestPredictionsPath = @"/predictions/";
static NSString * const GBRequestMultiPredictionsPath = @"/multiPredictions";
static NSString * const GBRequestSchedulePath = @"/schedule";
static NSString * const GBRequestMessagesPath = @"/messages";
static NSString * const GBRequestBuildingsPath = @"/buildings";

/*
@interface GBRequestConfig : NSObject

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *routeConfigURL;
//@property (nonatomic, strong) NSString *baseURL;
//@property (nonatomic, strong) NSString *baseURL;
//@property (nonatomic, strong) NSString *baseURL;
//@property (nonatomic, strong) NSString *baseURL;

@end

@implementation GBRequestConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)gtbusesConfig {
    GBRequestConfig *herokuConfig = [[GBRequestConfig alloc] init];
    herokuConfig.baseURL = @"https://gtbuses.herokuapp.com";
    herokuConfig.ro
    return herokuConfig;
}

+ (instancetype)nextbusConfig {
    GBRequestConfig *herokuConfig = [[GBRequestConfig alloc] init];
    
    return herokuConfig;
}

@end*/

@implementation GBRequestHandler

#pragma mark - Requests

- (void)routeConfig {
    [self getRequestWithURL:[self routeConfigURL]];
}

- (void)locationsForRoute:(NSString *)tag {
    NSString *baseURL = [self locationsBaseURL];
    [self getRequestWithURL:FORMAT(@"%@%@", baseURL, tag)];
}

- (void)predictionsForRoute:(NSString *)tag {
    NSString *baseURL = [self predictionsBaseURL];
    [self getRequestWithURL:FORMAT(@"%@%@", baseURL, tag)];
}

- (void)multiPredictionsForStops:(NSString *)parameterList {
    [self getRequestWithURL:FORMAT(@"%@%@", [self multiPredictionsBaseURL], parameterList)];
}

- (void)schedule {
    [self getRequestWithURL:[self scheduleURL]];
}

- (void)messages {
    [self getRequestWithURL:[self messagesURL]];
}

- (void)buildings {
    [self getRequestWithURL:[self buildingsURL]];
}

+ (NSString *)errorStringForCode:(NSInteger)code {
    NSString *errorString;
    switch (code) {
        case 400: errorString = NSLocalizedString(@"BAD_REQUEST_ERROR", @"400 Bad request error"); break;
        case 404: errorString = NSLocalizedString(@"RESOURCE_ERROR", @"404 Not found"); break;
        case 500: errorString = NSLocalizedString(@"INTERNAL_SERVER_ERROR", @"500 Internal server error"); break;
        case 503: errorString = NSLocalizedString(@"TIMED_OUT_ERROR", @"503 Timed out"); break;
        case 1008: case 1009: errorString = NSLocalizedString(@"NO_INTERNET_ERROR", @"1008/1009 No internet connection"); break;
        case GBRequestParseError: errorString = NSLocalizedString(@"PARSING_ERROR", @"Error parsing response xml"); break;
        case GBRequestNextbusError: errorString = NSLocalizedString(@"NEXTBUS_ERROR", @"Nextubs returned an error"); break;
        default: errorString = NSLocalizedString(@"DEFAULT_ERROR", @"Default HTTP response error"); break;
    }
    return FORMAT(@"%@ (-%li)", errorString, (long) ABS(code));
}

+ (BOOL)isNextBusError:(NSDictionary *)dictionary {
    NSDictionary *nextBusError = dictionary[@"body"][@"Error"];
    if (nextBusError) {
        return YES;
    }
    return NO;
}

#pragma mark - URLs

- (NSString *)routeConfigURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestRouteConfigPath];
    }
    return url;
}

- (NSString *)locationsBaseURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestLocationsPath];
    }
    return url;
}

- (NSString *)predictionsBaseURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestPredictionsPath];
    }
    return url;
}

- (NSString *)multiPredictionsBaseURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestMultiPredictionsPath];
    }
    return url;
}

- (NSString *)scheduleURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestSchedulePath];
    }
    return url;
}

- (NSString *)messagesURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestMessagesPath];
    }
    return url;
}

- (NSString *)buildingsURL {
    static NSString *url;
    if (!url) {
        url = [GBRequestBaseURL stringByAppendingString:GBRequestBuildingsPath];
    }
    return url;
}

@end
