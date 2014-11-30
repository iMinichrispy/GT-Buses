//
//  GBBusAnnotationView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@class GBBusAnnotation;
@interface GBBusAnnotationView : MKAnnotationView

- (void)setupForAnnotation:(GBBusAnnotation *)annotation;
- (void)updateArrowImageRotation;
- (void)setIdentifierVisible:(BOOL)visible;

@end
