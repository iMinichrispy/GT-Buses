//
//  MKMapView+AppStoreImages.m
//  GT-Buses
//
//  Created by Alex Perez on 8/23/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "MKMapView+AppStoreMap.h"

#import "GBRoute.h"
#import "GBBusAnnotation.h"
#import "GBColors.h"

@implementation MKMapView (AppStoreMap)

- (void)showBusesWithRoute:(GBRoute *)route {
    if ([route.tag isEqualToString:@"red"]) {
        GBBusAnnotation *bus1 = [[GBBusAnnotation alloc] init];
        bus1.color = [route.color darkerColor:0.5];
        bus1.heading = 90;
        [bus1 setCoordinate:CLLocationCoordinate2DMake(33.77815, -84.3984)];
        [self addAnnotation:bus1];
        
        GBBusAnnotation *bus2 = [[GBBusAnnotation alloc] init];
        bus2.color = [route.color darkerColor:0.5];
        bus2.heading = 180;
        [bus2 setCoordinate:CLLocationCoordinate2DMake(33.773, -84.39203)];
        [self addAnnotation:bus2];
        
        GBBusAnnotation *bus3 = [[GBBusAnnotation alloc] init];
        bus3.color = [route.color darkerColor:0.5];
        bus3.heading = 270;
        [bus3 setCoordinate:CLLocationCoordinate2DMake(33.77132, -84.3955)];
        [self addAnnotation:bus3];
        
        GBBusAnnotation *bus4 = [[GBBusAnnotation alloc] init];
        bus4.color = [route.color darkerColor:0.5];
        bus4.heading = 0;
        [bus4 setCoordinate:CLLocationCoordinate2DMake(33.7788, -84.4041907)];
        [self addAnnotation:bus4];
    } else if ([route.tag isEqualToString:@"blue"]) {
        GBBusAnnotation *bus1 = [[GBBusAnnotation alloc] init];
        bus1.color = [route.color darkerColor:0.5];
        bus1.heading = 90;
        [bus1 setCoordinate:CLLocationCoordinate2DMake(33.77823, -84.3973)];
        [self addAnnotation:bus1];
        
        GBBusAnnotation *bus2 = [[GBBusAnnotation alloc] init];
        bus2.color = [route.color darkerColor:0.5];
        bus2.heading = 180;
        [bus2 setCoordinate:CLLocationCoordinate2DMake(33.773, -84.3919)];
        [self addAnnotation:bus2];
        
        GBBusAnnotation *bus3 = [[GBBusAnnotation alloc] init];
        bus3.color = [route.color darkerColor:0.5];
        bus3.heading = 270;
        [bus3 setCoordinate:CLLocationCoordinate2DMake(33.77125, -84.3955)];
        [self addAnnotation:bus3];
        
        GBBusAnnotation *bus4 = [[GBBusAnnotation alloc] init];
        bus4.color = [route.color darkerColor:0.5];
        bus4.heading = 0;
        [bus4 setCoordinate:CLLocationCoordinate2DMake(33.7788, -84.4041907)];
        [self addAnnotation:bus4];
    }
}

+ (NSString *)predictionsStringForRoute:(GBRoute *)route {
    if ([route.tag isEqualToString:@"red"])
        return @"Next: 1, 2, 3";
    else if ([route.tag isEqualToString:@"blue"])
        return @"Next: 5, 6, 7";
    return @"No Predictions";
}

@end
