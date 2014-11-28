//
//  GBBusAnnotationView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@interface GBBusAnnotationView : MKAnnotationView

- (void)updateArrowImageRotation;
- (void)setIdentifierVisible:(BOOL)visible;

@end
