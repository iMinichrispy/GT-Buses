//
//  BusStopAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BusStopAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString *tag;

@end
