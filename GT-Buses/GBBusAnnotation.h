//
//  GBBusAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@class GBBus;
@interface GBBusAnnotation : MKPointAnnotation

@property (nonatomic, strong) GBBus *bus;

- (instancetype)initWithBus:(GBBus *)bus;

@end
