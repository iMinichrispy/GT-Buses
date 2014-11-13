//
//  GBStop.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStop.h"

#import "GBRoute.h"

@implementation NSDictionary (GBStop)

- (GBStop *)toStop {
    GBStop *stop = [[GBStop alloc] init];
    stop.title = self[@"title"];
    stop.tag = self[@"tag"];
    stop.routeTag = self[@"routeTag"];
    stop.hexColor = self[@"hexColor"];
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
        
        _hexColor = route.hexColor;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{@"title":_title, @"stopTag":_tag,  @"routeTag":_route.tag, @"hexColor":_hexColor};
    return dictionary;
}

@end
