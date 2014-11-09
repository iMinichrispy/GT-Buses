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
static NSString * const GBRequestBaseURL = @"https://gtbuses.herokuapp.com";
#else
static NSString * const GBRequestBaseURL = @"http://localhost:5000";
#endif

static NSString * const GBRequestRouteConfigPath = @"/routeConfig";
static NSString * const GBRequestLocationsPath = @"/locations/";
static NSString * const GBRequestPredictionsPath = @"/predictions/";
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
    [self getRequestWithURL:FORMAT(@"%@%@%@", baseURL, tag, @"?config=true")];
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
    [self getRequestWithURL:[GBRequestBaseURL stringByAppendingString:GBRequestTogglePartyPath]];
}
#endif

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
