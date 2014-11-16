//
//  GBStop.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStop.h"

#import "GBRoute.h"
#import "GBDirection.h"

@implementation NSDictionary (GBStop)

- (GBStop *)toStop {
    GBStop *stop = [[GBStop alloc] init];
    stop.title = self[@"title"];
    stop.tag = self[@"stopTag"];
    stop.routeTag = self[@"routeTag"];
    stop.hexColor = self[@"hexColor"];
    NSLog(@"%@",self[@"direction"]);
    stop.direction = [self[@"direction"] toDirection];
    return stop;
}

@end

@implementation GBStop

- (instancetype)initWithRoute:(GBRoute *)route title:(NSString *)title tag:(NSString *)tag {
    self = [super init];
    if (self) {
        _route = route;
        _title = title;
        _tag = tag;
        _favorite = NO;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{@"title":_title, @"stopTag":_tag,  @"routeTag":_route.tag, @"hexColor":_route.hexColor, @"direction":[_direction toDictionary]};
    return dictionary;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBStop title: %@, tag: %@, route: %@, coordinates: (%f, %f)>", _title, _tag, _route.tag, _lat, _lon];
}

@end
