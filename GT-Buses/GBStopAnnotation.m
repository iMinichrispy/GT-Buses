//
//  GBBusStopAnnotation.m
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStopAnnotation.h"

#import "GBStop.h"

@implementation GBStopAnnotation

- (instancetype)initWithStop:(GBStop *)stop {
    self = [super init];
    if (self) {
        _stop = stop;
    }
    return self;
}

@end
