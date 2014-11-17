//
//  GBStopGroup.m
//  GT-Buses
//
//  Created by Alex Perez on 11/16/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStopGroup.h"

#import "GBStop.h"
#import "GBDirection.h"

@implementation GBStopGroup

- (instancetype)initWithStop:(GBStop *)stop {
    self = [super init];
    if (self) {
        _stops = @[stop];
        _key = [NSString stringWithFormat:@"%@%@", stop.title, stop.direction.tag];
    }
    return self;
}
- (void)addStop:(GBStop *)stop {
    _stops = [_stops arrayByAddingObject:stop];
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    return [_key isEqualToString:((GBStopGroup *)object).key];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBStopGroup Stops: %lu, Distance: %f>", (unsigned long)_stops.count, _distance];
}

- (GBStop *)firstStop {
    return [_stops firstObject];
}

@end
