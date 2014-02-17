//
//  ViewController.h
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RequestHandler.h"
#import "XMLReader.h"
#import "Route.h"
#import "BusAnnotation.h"
#import "BusStopAnnotation.h"
#import "BusRouteLine.h"
#import "Colors.h"
#import "MapHandler.h"
#import "MFSideMenu.h"

@interface ViewController : UIViewController <RequestHandlerDelegate,CLLocationManagerDelegate> {
    MKMapView *mapView;
    UISegmentedControl *busRouteControl;
    UIView *busrouteControlView;
    UIActivityIndicatorView *activityIndicator;
}

@end
