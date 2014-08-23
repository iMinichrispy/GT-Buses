//
//  GBRequestHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestHandler.h"

#define API_URL @"http://m.cip.gatech.edu/widget/buses/content/api"

static NSString * const GBAPIURL =              @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=";
static NSString * const GBRouteConfigURL =      @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=routeConfig";
static NSString * const GBBusLocationsURL =     @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=vehicleLocations&r=";
static NSString * const GBBusPredictionsURL =   @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=predictionsForMultiStops&r=";
static NSString * const GBMessagesURL =         @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=messages";

@implementation GBRequestHandler

- (void)routeConfig {
    [self getRequestWithURL:GBRouteConfigURL];
}

- (void)positionForBus:(NSString *)tag {
    [self getRequestWithURL:[NSString stringWithFormat:@"%@%@", GBBusLocationsURL, tag]];
}

- (void)predictionsForBus:(NSString *)tag {
    [self getRequestWithURL:[NSString stringWithFormat:@"%@%@", GBBusPredictionsURL, tag]];
}

- (void)messages {
    [self getRequestWithURL:GBMessagesURL];
}

@end
