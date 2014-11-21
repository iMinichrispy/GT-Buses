//
//  GBBusAnnotation.m
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBusAnnotation.h"

@implementation GBBusAnnotation

- (instancetype)initWithBus:(GBBus *)bus {
    self = [super init];
    if (self) {
        _bus = bus;
    }
    return self;
}

@end
