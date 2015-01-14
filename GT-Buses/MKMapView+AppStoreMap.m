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
#import "GBStop.h"

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
    
    NSMutableArray *annotations = [NSMutableArray new];
    for (NSDictionary *dictionary in buses) {
        GBBus *bus = [[GBBus alloc] init];
        bus.color = route.color;
        bus.heading = [dictionary[@"heading"] intValue];
        
        GBBusAnnotation *busAnnotation = [[GBBusAnnotation alloc] initWithBus:bus];
        [busAnnotation setCoordinate:CLLocationCoordinate2DMake([dictionary[@"lat"] floatValue], [dictionary[@"lon"] floatValue])];
        [annotations addObject:busAnnotation];
    }
    [self addAnnotations:annotations];
}

+ (NSString *)predictionsStringForRoute:(GBRoute *)route {
    NSArray *predictions;
    if ([route.tag isEqualToString:@"red"])
        predictions = @[@{@"minutes":@1}, @{@"minutes":@5}, @{@"minutes":@9}];
    else if ([route.tag isEqualToString:@"blue"])
        predictions = @[@{@"minutes":@1}, @{@"minutes":@7}, @{@"minutes":@10}];
    return [GBStop predictionsStringForPredictions:predictions];
}

+ (NSString *)selectedStopTagForRoute:(GBRoute *)route {
    if ([route.tag isEqualToString:@"red"]) return @"centrstud";
    else if ([route.tag isEqualToString:@"blue"]) return @"cherfers";
    else if ([route.tag isEqualToString:@"green"]) return @"studcent_ib";
    else if ([route.tag isEqualToString:@"trolley"]) return @"techsqua";
    return nil;
}

@end
