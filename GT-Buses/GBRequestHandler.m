//
//  GBRequestHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestHandler.h"

#import "GBConstants.h"

#define API_URL @"http://m.cip.gatech.edu/widget/buses/content/api"

static NSString * const GBRouteConfigURL =      @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=routeConfig";
static NSString * const GBBusLocationsURL =     @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=vehicleLocations&r=";
static NSString * const GBBusPredictionsURL =   @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=predictionsForMultiStops&r=";
static NSString * const GBMessagesURL =         @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=messages";

@implementation GBRequestHandler

- (void)routeConfig {
    [self getRequestWithURL:GBRouteConfigURL];
}

- (void)locationsForRoute:(NSString *)tag {
    [self getRequestWithURL:FORMAT(@"%@%@", GBBusLocationsURL, tag)];
}

- (void)predictionsForRoute:(NSString *)tag {
    [self getRequestWithURL:FORMAT(@"%@%@", GBBusPredictionsURL, tag)];
}

- (void)messages {
    [self getRequestWithURL:GBMessagesURL];
}

@end
