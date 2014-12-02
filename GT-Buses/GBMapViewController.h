//
//  GBMapViewController.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class MKMapView;
@interface GBMapViewController : UIViewController

@property (nonatomic, strong, readonly) MKMapView *mapView;

@end
