//
//  BusAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BusAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString *busIdentifier;
@property (nonatomic, strong) NSNumber *heading;

@end
