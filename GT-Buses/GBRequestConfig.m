//
//  GBRequestConfig.m
//  GT-Buses
//
//  Created by Alex Perez on 12/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestConfig.h"

#if LOCAL_SERVER && TARGET_IPHONE_SIMULATOR
static NSString *const GBRequestHerokuBaseURL = @"http://localhost:5000";
#else
static NSString *const GBRequestHerokuBaseURL = @"https://gtbuses.herokuapp.com";
#endif

//static NSString *const GBRequestBaseURL = @"http://localhost:5000";
//static NSString *const GBRequestBaseURL = @"https://gtbuses.herokuapp.com";
//
//static NSString *const GBRequestRouteConfigPath = @"/routeConfig";
//static NSString *const GBRequestLocationsPath = @"/locations/";
//static NSString *const GBRequestPredictionsPath = @"/predictions/";
//static NSString *const GBRequestMultiPredictionsPath = @"/multiPredictions";
//static NSString *const GBRequestSchedulePath = @"/schedule";
//static NSString *const GBRequestMessagesPath = @"/messages";
//static NSString *const GBRequestBuildingsPath = @"/buildings";



//// public xml feed:
//// http://webservices.nextbus.com/service/publicXMLFeed?command=agencyList
//// http://webservices.nextbus.com/service/publicXMLFeed?a=mit&command=routeConfig

NSString *const GBGeorgiaTechAgency = @"georgia-tech";

@implementation GBRequestConfig

- (instancetype)initWithAgency:(NSString *)agency {
    self = [super init];
    if (self) {
        _agency = agency;
        if ([_agency isEqualToString:GBGeorgiaTechAgency]) {
            [self setSource:GBRequestConfigSourceHeroku];
        } else {
            [self setSource:GBRequestConfigSourceNextbusPublic];
        }
    }
    return self;
}

- (void)setSource:(GBRequestConfigSource)source {
    if (_source != source) {
        _source = source;
        
        if (source == GBRequestConfigSourceHeroku) {
            _baseURL = GBRequestHerokuBaseURL;
            _routeConfigURL = [_baseURL stringByAppendingString:@"/routeConfig"];
            _locationsBaseURL = [_baseURL stringByAppendingString:@"/locations/"];
            _predictionsBaseURL = [_baseURL stringByAppendingString:@"/predictions/"];
            _multiPredictionsBaseURL = [_baseURL stringByAppendingString:@"/multiPredictions"];
            _scheduleURL = [_baseURL stringByAppendingString:@"/schedule"];
            _messagesURL = [_baseURL stringByAppendingString:@"/messages"];
            _buildingsURL = [_baseURL stringByAppendingString:@"/buildings"];
        } else if (source == GBRequestConfigSourceNextbusPublic) {
            _baseURL = [NSString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?a=%@", _agency];
            _routeConfigURL = [_baseURL stringByAppendingString:@"&command=routeConfig"];
#warning &t=0
            _locationsBaseURL = [_baseURL stringByAppendingString:@"&command=vehicleLocations&t=0"];
            _predictionsBaseURL = nil;
            _multiPredictionsBaseURL = [_baseURL stringByAppendingString:@"&command=predictionsForMultiStops"]; // &stops=%@%%7C%@
            _scheduleURL = [_baseURL stringByAppendingString:@"&command=schedule"]; //&r=boston
            _messagesURL = [_baseURL stringByAppendingString:@"&command=messages"];
            _buildingsURL = nil;
            //NSString *parameter = [NSString stringWithFormat:@"&stops=%@%%7C%@", stop.route.tag, stop.tag]
        }
    }
}

@end
