//
//  BusAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Colors.h"

@interface BusAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString *busIdentifier;
@property (nonatomic, readwrite) int heading;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImageView *arrowImageView;

- (void)updateHeading;

@end
