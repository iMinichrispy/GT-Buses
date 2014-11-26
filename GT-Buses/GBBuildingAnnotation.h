//
//  GBBuildingAnnotation.h
//  GT-Buses
//
//  Created by Alex Perez on 11/20/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;
@import CoreLocation;

@class GBBuilding;
@interface GBBuildingAnnotation : MKPointAnnotation

@property (nonatomic, strong) GBBuilding *building;

- (instancetype)initWithBuilding:(GBBuilding *)building;

@end
