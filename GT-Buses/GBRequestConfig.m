//
//  GBRequestConfig.m
//  GT-Buses
//
//  Created by Alex Perez on 12/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestConfig.h"

#import "GBAgency.h"

#if LOCAL_SERVER && TARGET_IPHONE_SIMULATOR
NSString *const GBRequestHerokuBaseURL = @"http://localhost:5000";
#else
NSString *const GBRequestHerokuBaseURL = @"https://gtbuses.herokuapp.com";
#endif

@implementation GBRequestConfig

- (instancetype)initWithAgency:(NSString *)agency {
    self = [super init];
    if (self) {
        _agency = agency;
        GBRequestConfigSource source = ([_agency isEqualToString:GBGeorgiaTechAgencyTag]) ? GBRequestConfigSourceHeroku : GBRequestConfigSourceNextBusPublic;
        _source = source;
        [self setupForSource:_source];
    }
    return self;
}

- (void)setupForSource:(GBRequestConfigSource)source {
    if (source == GBRequestConfigSourceHeroku) {
        _baseURL = GBRequestHerokuBaseURL;
        _routeConfigURL = [_baseURL stringByAppendingString:@"/routeConfig"];
        _locationsBaseURL = [_baseURL stringByAppendingString:@"/locations/"];
        _predictionsBaseURL = [_baseURL stringByAppendingString:@"/predictions/"];
        _multiPredictionsBaseURL = [_baseURL stringByAppendingString:@"/multiPredictions"];
        _scheduleURL = [_baseURL stringByAppendingString:@"/schedule"];
        _messagesURL = [_baseURL stringByAppendingString:@"/messages"];
    } else if (source == GBRequestConfigSourceNextBusPublic) {
        _baseURL = [NSString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?a=%@", _agency];
        _routeConfigURL = [_baseURL stringByAppendingString:@"&command=routeConfig"];
        _locationsBaseURL = [_baseURL stringByAppendingString:@"&command=vehicleLocations&t=0"];
        _predictionsBaseURL = nil;
        _multiPredictionsBaseURL = [_baseURL stringByAppendingString:@"&command=predictionsForMultiStops"];
        _scheduleURL = [_baseURL stringByAppendingString:@"&command=schedule"];
        _messagesURL = [_baseURL stringByAppendingString:@"&command=messages"];
    }
}

@end
