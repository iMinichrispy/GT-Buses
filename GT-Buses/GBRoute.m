//
//  GBRoute.m
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRoute.h"

#import "GBColors.h"
#import "GBStop.h"
#import "GBDirection.h"
#import "GBConstants.h"

float const kMapRegionPadding = 0.0005f;

@interface GBRoute ()

+ (MKCoordinateRegion)regionForPaths:(NSArray *)paths;

@end

@implementation NSDictionary (Route)

- (GBRoute *)xmlToRoute {
    NSString *tag = self[@"tag"];
    NSString *title = [tag capitalizedString];
    
    GBRoute *route = [[GBRoute alloc] initWithTitle:title tag:tag];
    route.paths = self[@"path"];
    route.region = [GBRoute regionForPaths:route.paths];
    route.hexColor = self[@"color"];
    route.color = [UIColor colorWithHexString:route.hexColor];
    
    NSArray *directions = self[@"direction"];
    if (![directions isKindOfClass:[NSArray class]]) directions = @[directions];
    route.directions = directions;
    
    NSMutableDictionary *directionLookup = [NSMutableDictionary new];
    for (NSDictionary *dictionary in directions) {
        NSArray *stops = dictionary[@"stop"];
        GBDirection *direction = [[GBDirection alloc] initWithTitle:dictionary[@"title"] tag:dictionary[@"tag"]];
        direction.oneDirection = [directions count] == 1;
        if (![stops isKindOfClass:[NSArray class]]) stops = @[stops];
        for (NSDictionary *stop in stops) {
            NSString *stopTag = stop[@"tag"];
            directionLookup[stopTag] = direction;
        }
    }
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    NSArray *favoriteStops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
    
    NSMutableArray *stops = [NSMutableArray new];
    for (NSDictionary *busStop in self[@"stop"]) {
        GBStop *stop = [busStop xmlToStop];
        stop.route = route;
        stop.direction = directionLookup[stop.tag];
        
        for (NSDictionary *favoriteStop in favoriteStops) {
            if ([favoriteStop[@"tag"] isEqualToString:stop.tag] && [favoriteStop[@"route"][@"tag"] isEqualToString:stop.route.tag]) {
                stop.favorite = YES;
                break;
            }
        }
        [stops addObject:stop];
    }
    route.stops = stops;
    
    return route;
}

- (GBRoute *)toRoute {
    GBRoute *route = [[GBRoute alloc] initWithTitle:self[@"title"] tag:self[@"tag"]];
    route.hexColor = self[@"hexColor"];
    route.color = [UIColor colorWithHexString:route.hexColor];
    return route;
}

@end

@implementation GBRoute

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag {
    self = [super init];
    if (self) {
        self.title = title;
        self.tag = tag;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{@"tag":_tag, @"title":_title, @"hexColor":_hexColor};
    return dictionary;
}

+ (MKCoordinateRegion)regionForPaths:(NSArray *)paths {
    float minLat = FLT_MAX;
    float minLon = -FLT_MAX;
    float maxLat = 0;
    float maxLon = 0;

#warning test this out
//    MKMapRect zoomRect = MKMapRectNull;
//    for (id <MKAnnotation> annotation in mapView.annotations)
//    {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
//        zoomRect = MKMapRectUnion(zoomRect, pointRect);
//    }
//    [mapView setVisibleMapRect:zoomRect animated:YES];
    
    // Loop through all paths and find the min lat/lon and max lat/lon
    for (NSDictionary *path in paths) {
        NSArray *points = path[@"point"];
        for (NSDictionary *point in points) {
            float lat = [point[@"lat"] floatValue];
            float lon = [point[@"lon"] floatValue];
            
            minLat = fminf(minLat, lat);
            minLon = fmaxf(minLon, lon);
            
            maxLat = fmaxf(maxLat, lat);
            maxLon = fminf(maxLon, lon);
        }
    }
    
    CLLocationCoordinate2D coordinateMin = CLLocationCoordinate2DMake(minLat, minLon);
    CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(maxLat, maxLon);
    
    MKMapPoint lowerLeft = MKMapPointForCoordinate(coordinateMin);
    MKMapPoint upperRight = MKMapPointForCoordinate(coordinateMax);
    
    MKMapRect mapRect = MKMapRectMake(lowerLeft.x, lowerLeft.y, upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    region.span.latitudeDelta = maxLat - minLat + kMapRegionPadding;
    region.span.longitudeDelta = minLon - maxLon + kMapRegionPadding;
    
    return region;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Title: %@, Tag: %@>", self.title, self.tag];
}

@end
