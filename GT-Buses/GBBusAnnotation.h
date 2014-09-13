//
//  BusAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@interface GBBusAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString *busIdentifier;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic) NSInteger heading;

- (void)updateArrowImageRotation;

@end
