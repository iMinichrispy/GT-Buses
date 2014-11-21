//
//  GBBuildingAnnotation.m
//  GT-Buses
//
//  Created by Alex Perez on 11/20/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBuildingAnnotation.h"

#import "GBBuilding.h"

@implementation GBBuildingAnnotation

- (instancetype)initWithBuilding:(GBBuilding *)building {
    if (self) {
        _building = building;
        self.title = _building.name;
        self.subtitle = _building.address;
        self.coordinate = CLLocationCoordinate2DMake(_building.lat, _building.lon);
    }
    return self;
}

@end
