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

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface ViewController () {
    NSTimer *refreshTimer;
    NSArray *busPositionData;
    NSMutableArray *routes;
    UILabel *errorConnectingLabel;
    Route *selectedRoute;
    MapHandler *mapHandler;
    long long lastLocationUpdate;
    long long lastPredictionUpdate;
}

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = BLUE_COLOR;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
        self.navigationController.navigationBar.tintColor = BLUE_COLOR;
    
    self.navigationController.navigationBar.topItem.title = @"GT Buses";
    self.navigationController.navigationBar.translucent = NO;
    if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")))
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
    aboutButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : BLUE_COLOR;
    self.navigationItem.leftBarButtonItem = aboutButton;
    
//    UIImage *faceImage = [UIImage imageNamed:@"List.png"];
//    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
//    face.bounds = CGRectMake(0, 0, faceImage.size.width/2, faceImage.size.height/2);
//    [face setImage:faceImage forState:UIControlStateNormal];
    
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithCustomView:face];
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"List.png"] style:UIBarButtonItemStylePlain target:self action:nil];
//    listButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : BLUE_COLOR;
//    self.navigationItem.rightBarButtonItem = listButton;
    
    busRouteControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake((IS_IPAD) ? 15 : 5,5,SCREEN_WIDTH - ((IS_IPAD) ? 30 : 10),30)];
    busRouteControl.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : BLUE_COLOR;
    busRouteControl.segmentedControlStyle = UISegmentedControlStyleBar;
    busRouteControl.apportionsSegmentWidthsByContent = NO;
    busRouteControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [busRouteControl addTarget:self action:@selector(didChangeBusRoute) forControlEvents:UIControlEventValueChanged];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.center.x-10,12,20,20)];
    activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.hidesWhenStopped = YES;
    
    errorConnectingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 20)];
    errorConnectingLabel.textColor = [UIColor whiteColor];
    errorConnectingLabel.backgroundColor = [UIColor clearColor];
    errorConnectingLabel.textAlignment = NSTextAlignmentCenter;
    errorConnectingLabel.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    errorConnectingLabel.hidden = YES;
    
    busRouteControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    busRouteControlView.backgroundColor = BLUE_COLOR;
    busRouteControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    busRouteControlView.alpha = .9;
    [busRouteControlView addSubview:busRouteControl];
    [busRouteControlView addSubview:activityIndicator];
    [busRouteControlView addSubview:errorConnectingLabel];
    
    float mapHeight = SCREEN_HEIGHT - (20 + 44);
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, busRouteControlView.frame.origin.y, SCREEN_WIDTH, mapHeight)];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        mapView.rotateEnabled = NO;
    mapHandler = [[MapHandler alloc] init];
    mapView.delegate = mapHandler;
    mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775978,-84.399269), MKCoordinateSpanMake(0.025059,0.023190));
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    [self.view addSubview:busRouteControlView];
    
    routes = [NSMutableArray new];
    
    self.menuContainerViewController.menuWidth = (IS_IPAD) ? 200 : 150;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateEventOccurred:) name:MFSideMenuStateNotificationEvent object:nil];
    
    if (!(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")))
        [self updateVehicleLocations];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IS_IPAD) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    if (self.menuContainerViewController.menuState == MFSideMenuStateClosed)
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    else
        self.menuContainerViewController.panMode = MFSideMenuPanModeCenterViewController;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (refreshTimer)
        [refreshTimer invalidate];
    [mapView setShowsUserLocation:NO];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [mapView setShowsUserLocation:YES];
    [self updateVehicleLocations];
    if (!refreshTimer.isValid)
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateVehicleLocations) userInfo:nil repeats:YES];
}

- (void)aboutPressed {
    if (self.menuContainerViewController.menuState == MFSideMenuStateClosed)
        [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:^{}];
    else
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
}

- (void)handleResponse:(RequestHandler *)handler data:(id)data {
    [activityIndicator stopAnimating];
    
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error) {
        self.navigationItem.rightBarButtonItem =nil;
        errorConnectingLabel.hidden = YES;
        busRouteControl.hidden = NO;
        
        if ([handler.task isEqualToString:@"routeConfig"]) {
            if (busRouteControl.numberOfSegments == 0) {
                NSArray *newRoutes = [[dictionary objectForKey:@"body"] objectForKey:@"route"];
                for (int x = 0; x < [newRoutes count]; x++) {
                    NSDictionary *routeDic = [newRoutes objectAtIndex:x];
                    Route *route = [Route toRoute:routeDic];
                    [routes addObject:route];
                    [busRouteControl insertSegmentWithTitle:route.title atIndex:x animated:YES];
                }
                int index = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"selectedBusRoute"];
                if (busRouteControl.numberOfSegments > 0)
                    busRouteControl.selectedSegmentIndex = (index < busRouteControl.numberOfSegments) ? index : 0;
                
                if (!IS_IPAD)
                    busRouteControl.frame = CGRectMake(5,5,SCREEN_WIDTH - ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? 9 : 10),30);
                else if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
                    busRouteControl.frame = CGRectMake(15,5,SCREEN_HEIGHT - 30,30);
                
                [self didChangeBusRoute];
            }
        }
        else if ([handler.task isEqualToString:@"vehicleLocations"]) {
            long long newLocationUpdate = [[[[dictionary objectForKey:@"body"] objectForKey:@"lastTime"] objectForKey:@"time"] longLongValue];
            
            if (newLocationUpdate != lastLocationUpdate) {
                NSArray *vehicles = [[dictionary objectForKey:@"body"] objectForKey:@"vehicle"];
                if (vehicles) {
                    if (![vehicles isKindOfClass:[NSArray class]])
                        vehicles = [NSArray arrayWithObject:vehicles];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@",[BusAnnotation class]];
                    NSMutableArray *busAnnotations = [[mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    for (NSDictionary *busPosition in vehicles) {
                        BusAnnotation *annotation = [[BusAnnotation alloc] init];
                        annotation.busIdentifier = [busPosition objectForKey:@"id"];
                        annotation.color = [selectedRoute.color darkerColor:0.5];
                        
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
                        
                        annotation.heading = [[busPosition objectForKey:@"heading"] intValue];
                        
                        if (annotation.coordinate.latitude != [[busPosition objectForKey:@"lat"] doubleValue] || annotation.coordinate.longitude != [[busPosition objectForKey:@"lon"] doubleValue]) {
                            [UIView animateWithDuration:1 animations:^{
                                [annotation updateHeading];
                                [annotation setCoordinate:CLLocationCoordinate2DMake([[busPosition objectForKey:@"lat"] doubleValue], [[busPosition objectForKey:@"lon"] doubleValue])];
                            }];
                        }
                        
                        if (!found && [selectedRoute.tag isEqualToString:[busPosition objectForKey:@"routeTag"]])
                            [mapView addAnnotation:annotation];
                    }
                    
                    for (BusAnnotation *annotation in busAnnotations)
                        [mapView removeAnnotation:annotation];
                }
            }
            lastLocationUpdate = newLocationUpdate;
        }
        else if ([handler.task isEqualToString:@"vehiclePredictions"]) {
            long long newPredictionUpdate = [[[[dictionary objectForKey:@"body"] objectForKey:@"keyForNextTime"] objectForKey:@"value"] longLongValue];
            if (newPredictionUpdate != lastLocationUpdate) {
                NSArray *predictions = [[dictionary objectForKey:@"body"] objectForKey:@"predictions"];
                if (predictions) {
                    if (![predictions isKindOfClass:[NSArray class]])
                        predictions = [NSArray arrayWithObject:predictions];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@",[BusStopAnnotation class]];
                    NSMutableArray *busStopAnnotations = [[mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    for (NSDictionary *busStop in predictions) {
                        NSArray *predictionData = [[busStop objectForKey:@"direction"] objectForKey:@"prediction"];
                        NSArray *predictions;
                        if (predictionData) {
                            if (![predictionData isKindOfClass:[NSArray class]])
                                predictionData = [NSArray arrayWithObject:predictionData];
                            
                            if ([predictionData count] >= 3)
                                predictions = [predictionData subarrayWithRange:NSMakeRange(0, 3)];
                            else if ([predictionData count] > 0)
                                predictions = [predictionData subarrayWithRange:NSMakeRange(0, [predictionData count])];
                        }
                        
                        for (int x = 0; x < [busStopAnnotations count]; x++) {
                            BusStopAnnotation *busStopAnnotation = [busStopAnnotations objectAtIndex:x];
                            if ([busStopAnnotation.stopTag isEqualToString:[busStop objectForKey:@"stopTag"]]) {
                                if (predictions) {
                                    NSMutableString *subtitle = [NSMutableString stringWithFormat:@"Next: "];
                                    for (int x = 0; x < [predictions count]; x++) {
                                        NSDictionary *prediction = [predictions objectAtIndex:x];
                                        [subtitle appendFormat:(x == [predictions count]-1) ? @"%@" : @"%@, ", [prediction objectForKey:@"minutes"]];
                                    }
                                    busStopAnnotation.subtitle = ([predictions count] > 0) ? subtitle : @"No Predictions";
                                }
                                else
                                    busStopAnnotation.subtitle = @"No Predictions";
                                
                                [busStopAnnotations removeObject:busStopAnnotation];
                                break;
                            }
                        }
                    }
                }
            }
            lastPredictionUpdate = newPredictionUpdate;
        }
    }
    else
        [self handleError:nil code:4923 message:@"Error Parsing Data"];
}

- (void)handleError:(RequestHandler *)handler code:(int)code message:(NSString *)message {
    [activityIndicator stopAnimating];
    errorConnectingLabel.hidden = NO;
    busRouteControl.hidden = YES;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateVehicleLocations)];
    refreshButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : BLUE_COLOR;
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    if (code == 1008 || code == 1009)
        errorConnectingLabel.text = [NSString stringWithFormat:@"No Internet Connection (-%i)",code];
    else if (code == 400)
        errorConnectingLabel.text = [NSString stringWithFormat:@"Bad Request (-%i)",code];
    else if (code == 404)
        errorConnectingLabel.text = [NSString stringWithFormat:@"Resource Error (-%i)",code];
    else if (code == 500)
        errorConnectingLabel.text = [NSString stringWithFormat:@"Internal Server Error (-%i)",code];
    else if (code == 503)
        errorConnectingLabel.text = [NSString stringWithFormat:@"Timed Out (-%i)",code];
    else
        errorConnectingLabel.text = [NSString stringWithFormat:@"Error Connecting (-%i)",code];
}

- (void)updateVehicleLocations {
    if (selectedRoute) {
        RequestHandler *locationHandler = [[RequestHandler alloc] initWithDelegate:self task:@"vehicleLocations"];
        [locationHandler positionForBus:selectedRoute.tag];
        
        RequestHandler *predictionHandler = [[RequestHandler alloc] initWithDelegate:self task:@"vehiclePredictions"];
        [predictionHandler predictionsForBus:selectedRoute.tag];
    }
    else {
        RequestHandler *requestHandler = [[RequestHandler alloc] initWithDelegate:self task:@"routeConfig"];
        [activityIndicator startAnimating];
        errorConnectingLabel.hidden = YES;
        [requestHandler routeConfig];
    }
}

- (void)didChangeBusRoute {
    if (busRouteControl.selectedSegmentIndex > -1)
        [[NSUserDefaults standardUserDefaults] setInteger:busRouteControl.selectedSegmentIndex forKey:@"selectedBusRoute"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];
    
    selectedRoute = [routes objectAtIndex:busRouteControl.selectedSegmentIndex];
    [UIView animateWithDuration:.4 animations:^{
        if (IS_IPAD && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            [mapView setRegion:selectedRoute.region];
        else
            [mapView setRegion:[mapView regionThatFits:selectedRoute.region]];
    }];
    
    [self updateVehicleLocations];
    
    for (NSDictionary *path in selectedRoute.paths) {
        NSArray *points = [path objectForKey:@"point"];
        CLLocationCoordinate2D coordinates[[points count]];
        for (int y = 0; y < [points count]; y++) {
            NSDictionary *point = [points objectAtIndex:y];
            coordinates[y] = CLLocationCoordinate2DMake([[point objectForKey:@"lat"] floatValue],[[point objectForKey:@"lon"] floatValue]);
        }
        BusRouteLine *polygon = [BusRouteLine polylineWithCoordinates:coordinates count:[points count]];
        polygon.color = selectedRoute.color;
        [mapView addOverlay:polygon];
    }
    
    for (NSDictionary *stop in selectedRoute.stops) {
        BusStopAnnotation *stopPin = [[BusStopAnnotation alloc] init];
        stopPin.title = [stop objectForKey:@"title"];
        stopPin.tag = selectedRoute.tag;
        stopPin.stopTag = [stop objectForKey:@"tag"];
        stopPin.color = selectedRoute.color;
        [stopPin setCoordinate:CLLocationCoordinate2DMake([[stop objectForKey:@"lat"] doubleValue], [[stop objectForKey:@"lon"] doubleValue])];
        [mapView addAnnotation:stopPin];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(fixRegion) withObject:nil afterDelay:1];
}

- (void)fixRegion {
    [UIView animateWithDuration:.4 animations:^{
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            [mapView setRegion:selectedRoute.region];
        else
            [mapView setRegion:[mapView regionThatFits:selectedRoute.region]];
    }];
}

@end
