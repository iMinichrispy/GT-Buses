//
//  GBStopAnnotationView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@class GBFavoriteButton, GBStopAnnotation;
@interface GBStopAnnotationView : MKAnnotationView

@property (nonatomic, strong) GBFavoriteButton *favoriteButton;
@property (nonatomic, strong) UIImageView *stopImageView;

- (void)setupForAnnotation:(GBStopAnnotation *)annotation;

@end
