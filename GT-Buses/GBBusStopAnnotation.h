//
//  GBBusStopAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@class GBStop;
@interface GBBusStopAnnotation : MKPointAnnotation

@property (nonatomic, strong) GBStop *stop;

- (instancetype)initWithStop:(GBStop *)stop;

@end
