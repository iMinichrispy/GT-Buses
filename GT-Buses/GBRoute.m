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

@interface GBRoute ()

+ (MKMapRect)rectForPaths:(NSArray *)paths;

@end

@implementation NSDictionary (Route)

- (GBRoute *)xmlToRoute {
    NSString *tag = self[@"tag"];
    NSString *title = [tag capitalizedString];
    
    GBRoute *route = [[GBRoute alloc] initWithTitle:title tag:tag];
    route.paths = self[@"path"];
    route.mapRect = [GBRoute rectForPaths:route.paths];
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

+ (MKMapRect)rectForPaths:(NSArray *)paths {
    MKMapRect zoomRect = MKMapRectNull;
    for (NSDictionary *path in paths) {
        NSArray *points = path[@"point"];
        for (NSDictionary *point in points) {
            float lat = [point[@"lat"] floatValue];
            float lon = [point[@"lon"] floatValue];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
            MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
            MKMapRect pointRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0, 0);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    return zoomRect;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBRoute title: %@, tag: %@>", _title, _tag];
}

@end
