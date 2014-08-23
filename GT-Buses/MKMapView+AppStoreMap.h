//
//  MKMapView+AppStoreImages.h
//  GT-Buses
//
//  Created by Alex Perez on 8/23/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;
@import MapKit;

@class GBRoute;
@interface MKMapView (AppStoreMap)

- (void)showBusesWithRoute:(GBRoute *)route;
+ (NSString *)predictionsStringForRoute:(GBRoute *)route;

@end
