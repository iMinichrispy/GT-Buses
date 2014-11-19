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

#if !DEBUG || !TARGET_IPHONE_SIMULATOR
#define MASTER_PASSWORD @"verax"
static NSString * const GBRequestBaseURL = @"https://gtbuses.herokuapp.com";
#else
#define MASTER_PASSWORD @"temp"
static NSString * const GBRequestBaseURL = @"http://localhost:5000";
#endif

// public xml feed:
// http://webservices.nextbus.com/service/publicXMLFeed?command=agencyList
// http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=mit

static NSString * const GBRequestRouteConfigPath = @"/routeConfig";
static NSString * const GBRequestLocationsPath = @"/locations/";
static NSString * const GBRequestPredictionsPath = @"/predictions/";
static NSString * const GBRequestMultiPredictionsPath = @"/multiPredictions";
static NSString * const GBRequestSchedulePath = @"/schedule";
static NSString * const GBRequestMessagesPath = @"/messages";

static NSString * const GBRequestResetPath = @"/reset";
static NSString * const GBRequestUpdateStopsPath = @"/updateStops";
static NSString * const GBRequestTogglePartyPath = @"/toggleParty";

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

#if DEBUG
- (void)resetBackend {
    [self getRequestWithURL:[GBRequestBaseURL stringByAppendingString:GBRequestResetPath]];
}

- (void)updateStops {
    [self getRequestWithURL:[GBRequestBaseURL stringByAppendingString:GBRequestUpdateStopsPath]];
}

- (void)toggleParty {
    NSString *query = FORMAT(@"%@?password=%@", GBRequestTogglePartyPath, MASTER_PASSWORD);
    [self getRequestWithURL:[GBRequestBaseURL stringByAppendingString:query]];
}
#endif

+ (NSString *)errorStringForCode:(NSInteger)code {
    NSString *errorString;
    switch (code) {
        case 400: errorString = @"Bad Request"; break;
        case 404: errorString = @"Resource Error"; break;
        case 500: errorString = @"Internal Server Error"; break;
        case 503: errorString = @"Timed Out"; break;
        case 1008: case 1009: errorString = @"No Internet Connection"; break;
        case PARSE_ERROR_CODE: errorString = @"Parsing Error"; break;
        default: errorString = @"Error Connecting"; break;
    }
    return FORMAT(@"%@ (-%li)", errorString, (long)code);
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

@end
