//
//  ViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define IS_IPHONE ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
#define IS_HEIGHT_GTE_568 SCREEN_HEIGHT >= 568.0f
#define IS_IPHONE_5 (IS_IPHONE && IS_HEIGHT_GTE_568)

#define ROUTE_SETUP @{@"red":@"RedDot@2x.png", @"green":@"GreenDot@2x.png", @"blue":@"BlueDot@2x.png", @"trolley":@"YellowDot@2x.png", @"emory":@"RedDot@2x.png", @"night":@"RedDot@2x.png"}


@interface ViewController () {
    NSTimer *refreshTimer;
    NSArray *busPositionData;
    NSMutableArray *routes;
    Route *selectedRoute;
    UILabel *errorConnectingLabel;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationController.navigationBar.barTintColor = BLUE_COLOR;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
//    aboutButton.tintColor = [UIColor whiteColor];
//    self.navigationItem.leftBarButtonItem = aboutButton;
    
    busRouteControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10,5,300,30)];
    busRouteControl.tintColor = [UIColor whiteColor];
//    [busRouteControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Open-Sans" size:15.0]} forState:UIControlStateNormal];
    [busRouteControl addTarget:self action:@selector(didChangeBusRoute) forControlEvents:UIControlEventValueChanged];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150,12,20,20)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    
//    errorConnectingLabel = [[UILabel alloc]]
    
    busrouteControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 40)];
    busrouteControlView.backgroundColor = BLUE_COLOR;
    busrouteControlView.alpha = .9;
    [busrouteControlView addSubview:busRouteControl];
    [busrouteControlView addSubview:activityIndicator];
    
    float mapHeight = SCREEN_HEIGHT - (20 + 44);
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, busrouteControlView.frame.origin.y, SCREEN_WIDTH, mapHeight)];
    mapView.delegate = self;
    mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775083, -84.402408), MKCoordinateSpanMake(.03, .03));
    [self.view addSubview:mapView];
    [self.view addSubview:busrouteControlView];
    
    routes = [[NSMutableArray alloc] init];
    
    RequestHandler *requestHandler = [[RequestHandler alloc] initWithDelegate:self task:@"routeConfig"];
    [activityIndicator startAnimating];
    [requestHandler routeConfig];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (refreshTimer)
        [refreshTimer invalidate];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self updateVehicleLocations];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateVehicleLocations) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //if not connected
        //stop timer
    }
    else {
        //if connected
        
    }
}


- (void)aboutPressed {
    
}

- (void)handleResponse:(RequestHandler *)handler data:(id)data {
    [activityIndicator stopAnimating];
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    if (!error) {
        if ([handler.task isEqualToString:@"routeConfig"]) {
            NSArray *newRoutes = [[dictionary objectForKey:@"body"] objectForKey:@"route"];
            for (int x = 0; x < [newRoutes count]; x++) {
                NSDictionary *routeDic = [newRoutes objectAtIndex:x];
                Route *route = [Route toRoute:routeDic];
                [routes addObject:route];
                [busRouteControl insertSegmentWithTitle:route.title atIndex:x animated:NO];
            }
            busRouteControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedBusRoute"];
            
            [self didChangeBusRoute];
        }
        else if ([handler.task isEqualToString:@"vehicleLocations"]) {
            NSArray *vehicles = [[dictionary objectForKey:@"body"] objectForKey:@"vehicle"];
            if (vehicles) {
                
                if (![vehicles isKindOfClass:[NSArray class]])
                    vehicles = [NSArray arrayWithObject:vehicles];
//                NSLog(@"%@",vehicles);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@",  @"vehicleLocations"];
                NSMutableArray *busAnnotations = [[mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                
                for (NSDictionary *busPosition in vehicles) {
                    BusAnnotation *annotation = [[BusAnnotation alloc] init];
                    annotation.title = @"vehicleLocations";
                    annotation.busIdentifier = [busPosition objectForKey:@"id"];
//                    annotation.heading = [busPosition objectForKey:@"heading"];
                    
                    BOOL found = NO;
                    for (int x = 0; x < [busAnnotations count]; x++) {
                        BusAnnotation *busAnnotation = [busAnnotations objectAtIndex:x];
                        if ([busAnnotation isEqual:annotation]) {
                            [busAnnotations removeObject:busAnnotation];
                            annotation = busAnnotation;
                            found = YES;
                            break;
                        }
                    }
                    
                    if (annotation.coordinate.latitude != [[busPosition objectForKey:@"lat"] doubleValue] || annotation.coordinate.longitude != [[busPosition objectForKey:@"lon"] doubleValue]) {
                        [UIView animateWithDuration:1 animations:^{
                            [annotation setCoordinate:CLLocationCoordinate2DMake([[busPosition objectForKey:@"lat"] doubleValue], [[busPosition objectForKey:@"lon"] doubleValue])];
                        }];
                    }
                    
                    if (!found) {
                        [mapView addAnnotation:annotation];
                    }
                }
                
                for (BusAnnotation *annotation in busAnnotations) {
                    [mapView removeAnnotation:annotation];
                }
            }
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Parsing Data" message:@"An error occurred when parsing the XML Data. (-4923)" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)handleError:(RequestHandler *)handler code:(int)code message:(NSString *)message {
    [activityIndicator stopAnimating];
    [handler handleErrorCode:code message:message];
}

- (void)updateVehicleLocations {
    if (selectedRoute) {
        NSLog(@"Update: %@",selectedRoute.tag);
        RequestHandler *requestHandler = [[RequestHandler alloc] initWithDelegate:self task:@"vehicleLocations"];
        [requestHandler positionForBus:selectedRoute.tag];
    }
}

- (void)didChangeBusRoute {
    [[NSUserDefaults standardUserDefaults] setInteger:busRouteControl.selectedSegmentIndex forKey:@"selectedBusRoute"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];

    selectedRoute = [routes objectAtIndex:busRouteControl.selectedSegmentIndex];
    [mapView setRegion:[mapView regionThatFits:selectedRoute.region] animated:YES];

    [self updateVehicleLocations];
    
    for (NSDictionary *path in selectedRoute.paths) {
        NSArray *points = [path objectForKey:@"point"];
        CLLocationCoordinate2D coordinates[[points count]];
        for (int y = 0; y < [points count]; y++) {
            NSDictionary *point = [points objectAtIndex:y];
            coordinates[y] = CLLocationCoordinate2DMake([[point objectForKey:@"lat"] floatValue],[[point objectForKey:@"lon"] floatValue]);
        }
        MKPolyline *polygon = [MKPolyline polylineWithCoordinates:coordinates count:[points count]];
        [mapView addOverlay:polygon];
    }
    
    for (NSDictionary *stop in selectedRoute.stops) {
        BusStopAnnotation *stopPin = [[BusStopAnnotation alloc] init];
        stopPin.title = [stop objectForKey:@"title"];
        stopPin.subtitle = @"@4324234234";
        stopPin.tag = selectedRoute.tag;
        [stopPin setCoordinate:CLLocationCoordinate2DMake([[stop objectForKey:@"lat"] doubleValue], [[stop objectForKey:@"lon"] doubleValue])];
        [mapView addAnnotation:stopPin];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        line.strokeColor = selectedRoute.color;
        line.lineWidth = 6;
        line.alpha = .5;
        line.lineCap = kCGLineCapButt;
        return line;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation.title isEqualToString:@"vehicleLocations"]) {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Nil];
        UIImage *flagImage = [UIImage imageNamed:@"Arrow.png"];
        UIImage *color = [flagImage imageWithColor:selectedRoute.color];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        imageView.image = color;
//        imageView.transform = CGAffineTransformMakeRotation(<#CGFloat angle#>);
        [annotationView addSubview:imageView];
        
        annotationView.canShowCallout = NO;
//        annotationView.image = color;
        return annotationView;
    }
    else {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Nil];
        annotationView.frame = CGRectMake(0, 0, 10, 10);
        annotationView.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        NSString *imageForTag = [ROUTE_SETUP objectForKey:((BusStopAnnotation *)annotation).tag];
        NSString *imagePath = (imageForTag) ? imageForTag : @"RedDot@2x";
        imageView.image = [UIImage imageNamed:imagePath];
        [annotationView addSubview:imageView];
        return annotationView;
    }
}

@end
