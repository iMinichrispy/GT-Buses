//
//  MKMapView+AppStoreMap.m
//  GT-Buses
//
//  Created by Alex Perez on 8/23/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "MKMapView+AppStoreMap.h"

#import "GBRoute.h"
#import "GBBusAnnotation.h"
#import "GBColors.h"
#import "GBBus.h"

@implementation MKMapView (AppStoreMap)

- (void)showBusesWithRoute:(GBRoute *)route {
    NSArray *buses;
    if ([route.tag isEqualToString:@"red"]) {
        buses = @[@{@"lat":@33.77815, @"lon":@(-84.3984),  @"heading":@90},
                  @{@"lat":@33.773,   @"lon":@(-84.39203), @"heading":@180},
                  @{@"lat":@33.77132, @"lon":@(-84.3955),  @"heading":@270},
                  @{@"lat":@33.7788,  @"lon":@(-84.40419), @"heading":@0}];
    } else if ([route.tag isEqualToString:@"blue"]) {
        buses = @[@{@"lat":@33.77823, @"lon":@(-84.3973), @"heading":@270},
                  @{@"lat":@33.776,   @"lon":@(-84.392),  @"heading":@0},
                  @{@"lat":@33.77125, @"lon":@(-84.3955), @"heading":@90},
                  @{@"lat":@33.776,   @"lon":@(-84.4025), @"heading":@180}];
    }
    
    for (NSDictionary *dictionary in buses) {
        GBBus *bus = [[GBBus alloc] init];
        bus.color = [route.color darkerColor:0.5];
        bus.heading = [dictionary[@"heading"] intValue];
        
        GBBusAnnotation *busAnnotation = [[GBBusAnnotation alloc] initWithBus:bus];
        [busAnnotation setCoordinate:CLLocationCoordinate2DMake([dictionary[@"lat"] floatValue], [dictionary[@"lon"] floatValue])];
        [self addAnnotation:busAnnotation];
    }
}

+ (NSString *)predictionsStringForRoute:(GBRoute *)route {
    if ([route.tag isEqualToString:@"red"]) return @"Next: 1, 5, 9";
    else if ([route.tag isEqualToString:@"blue"]) return @"Next: 1, 7, 10";
    return @"No Predictions";
}

+ (NSString *)selectedStopTagForRoute:(GBRoute *)route {
    if ([route.tag isEqualToString:@"red"]) return @"centrstud";
    else if ([route.tag isEqualToString:@"blue"]) return @"cherfers";
    return nil;
}

@end
