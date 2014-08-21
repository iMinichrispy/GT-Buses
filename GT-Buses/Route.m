//
//  Route.m
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "Route.h"

#define REGION_SETUP @{@"red":@{@"centerLat":@33.774974,@"centerLon":@(-84.398013),@"spanLat":@0.014157,@"spanLon":@0.013101},                                                                                @"blue":@{@"centerLat":@33.774553,@"centerLon":@(-84.397973),@"spanLat":@0.014269,@"spanLon":@0.013205},  @"green":@{@"centerLat":@33.778637,@"centerLon":@(-84.398992),@"spanLat":@0.020040,@"spanLon":@0.018546},                        @"trolley":@{@"centerLat":@33.776728,@"centerLon":@(-84.394176),@"spanLat":@0.018577,@"spanLon":@0.017192},                       @"emory":@{@"centerLat":@33.790824,@"centerLon":@(-84.357531),@"spanLat":@0.090284,@"spanLon":@0.083565},                       @"night":@{@"centerLat":@33.775468,@"centerLon":@(-84.398033),@"spanLat":@0.013653,@"spanLon":@0.012635}, @"greenday":@{@"centerLat":@33.778637,@"centerLon":@(-84.398992),@"spanLat":@0.020040,@"spanLon":@0.018546},                  @"glc":@{@"centerLat":@33.779169,@"centerLon":@(-84.395217),@"spanLat":@0.010133,@"spanLon":@0.007740}}


//Red: (33.774974,-84.398013), Span: (0.014157,0.013101)
//Blue: (33.774553,-84.397973), Span: (0.014269,0.013205)
//Green: (33.778637,-84.398992), Span: (0.020040,0.018546)
//Trolley: (33.776728,-84.394176), Span: (0.018577,0.017192)
//Emory: (33.790824,-84.357531), Span: (0.090284,0.083565)
//Night:(33.775468,-84.398033), Span: (0.013653,0.012635)

@implementation NSDictionary (Route)

- (Route *)toRoute {
    NSString *lowercaseTitle = self[@"tag"];
    NSString *title = [NSString stringWithFormat:@"%@%@",[[lowercaseTitle substringToIndex:1] uppercaseString],[lowercaseTitle substringFromIndex:1] ];
    
    Route *route = [[Route alloc] initWithTitle:title tag:lowercaseTitle];
    route.paths = self[@"path"];
    route.region = [Route regionForTag:lowercaseTitle latMax:[self[@"latMax"] floatValue] latMin:[self[@"latMin"] floatValue] lonMax:[self[@"lonMax"] floatValue] lonMin:[self[@"lonMin"] floatValue]];
    route.stops = self[@"stop"];
    route.color = [UIColor colorWithHexString:self[@"color"]];
    return route;
}

@end

@implementation Route

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag {
    self = [super init];
    if (self) {
        self.title = title;
        self.tag = tag;
    }
    return self;
}

+ (MKCoordinateRegion)regionForTag:(NSString *)tag latMax:(float)latMax latMin:(float)latMin lonMax:(float)lonMax lonMin:(float)lonMin {
    MKCoordinateRegion region;
    
    NSDictionary *regionDic = REGION_SETUP[@"tag"];
    if (regionDic) {
        region.center.latitude = [regionDic[@"centerLat"] floatValue];
        region.center.longitude = [regionDic[@"centerLon"] floatValue];
        region.span.latitudeDelta = [regionDic[@"spanLat"] floatValue];
        region.span.longitudeDelta = [regionDic[@"spanLon"] floatValue];
        return region;
    }
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:latMin longitude:lonMin];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:latMax longitude:lonMax];
    
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    region.center.latitude = (locSouthWest.coordinate.latitude + locNorthEast.coordinate.latitude) / 2.0;
    region.center.longitude = (locSouthWest.coordinate.longitude + locNorthEast.coordinate.longitude) / 2.0;
    region.span.latitudeDelta = meters / (.00385 * (meters * meters) - (39.788 * meters) + 160685.138);
    region.span.longitudeDelta = 0;
    
    return region;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Title: %@, Tag: %@>", self.title, self.tag];
}

@end
