//
//  Route.m
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "Route.h"

#define REGION_SETUP @{                                                                                             @"red":@{@"centerLat":@33.774974,@"centerLon":@(-84.398013),@"spanLat":@0.014157,@"spanLon":@0.013101},                                                                                @"blue":@{@"centerLat":@33.774553,@"centerLon":@(-84.397973),@"spanLat":@0.014269,@"spanLon":@0.013205}, @"green":@{@"centerLat":@33.778637,@"centerLon":@(-84.398992),@"spanLat":@0.020040,@"spanLon":@0.018546},     @"trolley":@{@"centerLat":@33.776728,@"centerLon":@(-84.394176),@"spanLat":@0.018577,@"spanLon":@0.017192},   @"emory":@{@"centerLat":@33.790824,@"centerLon":@(-84.357531),@"spanLat":@0.090284,@"spanLon":@0.083565},      @"night":@{@"centerLat":@33.775468,@"centerLon":@(-84.398033),@"spanLat":@0.013653,@"spanLon":@0.012635}}

#define ROUTE_SETUP @{@"red":@"RedDot@2x.png", @"green":@"GreenDot@2x.png", @"blue":@"BlueDot@2x.png", @"trolley":@"YellowDot@2x.png", @"emory":@"RedDot@2x.png", @"night":@"RedDot@2x.png"}

//Red: (33.774974,-84.398013), Span: (0.014157,0.013101)
//Blue: (33.774553,-84.397973), Span: (0.014269,0.013205)
//Green: (33.778637,-84.398992), Span: (0.020040,0.018546)
//Trolley: (33.776728,-84.394176), Span: (0.018577,0.017192)
//Emory: (33.790824,-84.357531), Span: (0.090284,0.083565)
//Night:(33.775468,-84.398033), Span: (0.013653,0.012635)

@implementation Route
@synthesize title,tag;
@synthesize color;
@synthesize paths;
@synthesize region;

- (id)initWithTitle:(NSString *)newTitle tag:(NSString *)newTag {
    self = [super init];
    if (self) {
        self.title = newTitle;
        self.tag = newTag;
    }
    return self;
}

+ (Route *)toRoute:(NSDictionary *)dic {
    NSString *lowercaseTitle = [dic objectForKey:@"tag"];
    NSString *title = [NSString stringWithFormat:@"%@%@",[[lowercaseTitle substringToIndex:1] uppercaseString],[lowercaseTitle substringFromIndex:1] ];
    Route *route = [[Route alloc] initWithTitle:title tag:[dic objectForKey:@"tag"]];
    route.paths = [dic objectForKey:@"path"];
    route.region = [Route regionForTag:[dic objectForKey:@"tag"] latMax:[[dic objectForKey:@"latMax"] floatValue] latMin:[[dic objectForKey:@"latMin"] floatValue] lonMax:[[dic objectForKey:@"lonMax"] floatValue] lonMin:[[dic objectForKey:@"lonMin"] floatValue]];
    route.stops = [dic objectForKey:@"stop"];
    route.color = [Colors colorWithHexString:[dic objectForKey:@"color"]];
    return route;
}

+ (MKCoordinateRegion)regionForTag:(NSString *)tag latMax:(float)latMax latMin:(float)latMin lonMax:(float)lonMax lonMin:(float)lonMin {
    MKCoordinateRegion region;
    
    NSDictionary *regionDic = [REGION_SETUP objectForKey:tag];
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[regionDic objectForKey:@"centerLat"] floatValue], [[regionDic objectForKey:@"centerLon"] floatValue]);
//    return MKCoordinateRegionMakeWithDistance(center, 1000, 1000);
    
//    NSDictionary *regionDic = [REGION_SETUP objectForKey:tag];
    NSLog(@"%@ Region Setup: (%f,%f,%f,%f)",tag, [[regionDic objectForKey:@"centerLat"] floatValue],[[regionDic objectForKey:@"centerLon"] floatValue],[[regionDic objectForKey:@"spanLat"] floatValue],[[regionDic objectForKey:@"spanLon"] floatValue]);
    if (regionDic) {
        region.center.latitude = 33.778640;//[[regionDic objectForKey:@"centerLat"] floatValue];
        region.center.longitude = -84.398765;//[[regionDic objectForKey:@"centerLon"] floatValue];
        region.span.latitudeDelta = 0.020521;//[[regionDic objectForKey:@"spanLat"] floatValue];
        region.span.longitudeDelta = 0.018992;//[[regionDic objectForKey:@"spanLon"] floatValue];
        return region;
    }
    
//    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:latMin longitude:lonMin];
//    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:latMax longitude:lonMax];
//    
//    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
//    
//    region.center.latitude = (locSouthWest.coordinate.latitude + locNorthEast.coordinate.latitude) / 2.0;
//    region.center.longitude = (locSouthWest.coordinate.longitude + locNorthEast.coordinate.longitude) / 2.0;
//    region.span.latitudeDelta = meters / (.00385*(meters*meters)-(39.788*meters)+160685.138);
//    region.span.longitudeDelta = 0;
    
    return region;
}

@end
