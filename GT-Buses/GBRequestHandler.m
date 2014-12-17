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
#import "GBRequestConfig.h"
#import "GBRoute.h"

NSString *const GBRequestRouteConfigTask = @"GBRequestRouteConfigTask";
NSString *const GBRequestVehicleLocationsTask = @"GBRequestVehicleLocationsTask";
NSString *const GBRequestVehiclePredictionsTask = @"GBRequestVehiclePredictionsTask";
NSString *const GBRequestMultiPredictionsTask = @"GBRequestMultiPredictionsTask";
NSString *const GBRequestMessagesTask = @"GBRequestMessagesTask";
NSString *const GBRequestBuildingsTask = @"GBRequestBuildingsTask";

NSString *const GBRequestErrorDomain = @"com.alexperez.gtbuses.requestErrors";

@implementation GBRequestHandler

#pragma mark - Requests

- (void)agencyList {
    [self getRequestWithURL:FORMAT(@"%@%@",GBRequestHerokuBaseURL, @"/agencyList")];
}

- (void)routeConfig {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    [self getRequestWithURL:[requestConfig routeConfigURL]];
}

- (void)locationsForRoute:(GBRoute *)route {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    if (requestConfig.source == GBRequestConfigSourceHeroku) {
        [self getRequestWithURL:FORMAT(@"%@%@", [requestConfig locationsBaseURL], route.tag)];
    } else if (requestConfig.source == GBRequestConfigSourceNextbusPublic) {
        [self getRequestWithURL:FORMAT(@"%@&r=%@", [requestConfig locationsBaseURL], route.tag)];
    }
}

- (void)predictionsForRoute:(GBRoute *)route; {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    if (requestConfig.source == GBRequestConfigSourceHeroku) {
        NSString *baseURL = [requestConfig predictionsBaseURL];
        [self getRequestWithURL:FORMAT(@"%@%@", baseURL, route.tag)];
    } else if (requestConfig.source == GBRequestConfigSourceNextbusPublic) {
        if ([route.stopParameters length]) {
            [self multiPredictionsForStops:route.stopParameters];
        }
    }
}

- (void)multiPredictionsForStops:(NSString *)parameterList {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    [self getRequestWithURL:FORMAT(@"%@%@", [requestConfig multiPredictionsBaseURL], parameterList)];
}

- (void)schedule {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    [self getRequestWithURL:[requestConfig scheduleURL]];
}

- (void)messages {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    [self getRequestWithURL:[requestConfig messagesURL]];
}

- (void)buildings {
    GBRequestConfig *requestConfig = [[GBConfig sharedInstance] requestConfig];
    [self getRequestWithURL:[requestConfig buildingsURL]];
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

@end
