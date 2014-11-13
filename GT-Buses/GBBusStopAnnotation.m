//
//  GBBusStopAnnotation.m
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBusStopAnnotation.h"

#import "GBStop.h"

@implementation GBBusStopAnnotation

- (instancetype)initWithStop:(GBStop *)stop {
    self = [super init];
    if (self) {
        _stop = stop;
    }
    return self;
}

@end
