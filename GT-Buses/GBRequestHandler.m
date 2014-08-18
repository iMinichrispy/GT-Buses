//
//  GBRequestHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestHandler.h"

#define API_URL @"http://m.cip.gatech.edu/widget/buses/content/api"
#define BUS_LOCATIONS_URL @"http://www.nextbus.com/service/googleMapXMLFeed?command=vehicleLocations&a=georgia-tech&r="
#define BUS_PREDICTIONS_URL @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=predictionsForMultiStops&r="
#define ROUTE_CONFIG_URL @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=routeConfig"
#define MESSAGES_URL @"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=messages"
#define REFERER @"http://www.nextbus.com/googleMap/"

//http://www.nextbus.com/service/googleMapXMLFeed?command=vehicleLocations&a=georgia-tech&r=blue&t=1396353521341&key=812434079211
//- Referrer:

@implementation GBRequestHandler

- (NSString *)referrer {
    return REFERER;
}

- (void)routeConfig {
    [self getRequestWithURL:ROUTE_CONFIG_URL];
}

- (void)messages {
    [self getRequestWithURL:MESSAGES_URL];
}

- (void)positionForBus:(NSString *)tag {
    [self getRequestWithURL:[NSString stringWithFormat:@"http://gtwiki.info/nextbus/nextbus.php?a=georgia-tech&command=vehicleLocations&r=%@", tag]];
    
//    1396570930926
//    1396570935618
//    1396570940617
//    1396570945618
//    1396570950618
//    1396570987908
//    1396571058280

//    Keys:
//    812434079211


//    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0) - 10000;
//    NSLog(@"%lld",milliseconds);

//    [self getRequestWithURL:[NSString stringWithFormat:@"%@%@&t=%lld&key=812434079211", BUS_LOCATIONS_URL, tag, milliseconds]];
    
//    [self getRequestWithURL:@"http://www.nextbus.com/service/googleMapXMLFeed?command=vehicleLocations&a=georgia-tech&r=blue&t=1396570071706&key=812434079211"];

//    [self getRequestWithURL:@"http://www.nextbus.com/service/googleMapXMLFeed?command=vehicleLocations&a=georgia-tech&r=blue&t=1397248186199&key=0e522419a9ec9d16f4040a6000f1a1d5"];
//    [self getRequestWithURL:@"http://www.nextbus.com/api/pub/v1/agencies/georgia-tech/routes/green/stops/studcentr/predictions?coincident=true&direction=hub&key=0e522419a9ec9d16f4040a6000f1a1d5&timestamp=1397248186199"];

//http://www.nextbus.com/service/googleMapXMLFeed?command=vehicleLocations&a=georgia-tech&r=blue&t=1396353521341&key=812434079211
}

- (void)predictionsForBus:(NSString *)tag {
    [self getRequestWithURL:[NSString stringWithFormat:@"%@%@",BUS_PREDICTIONS_URL,tag]];
}

@end
