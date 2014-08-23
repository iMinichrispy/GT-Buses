//
//  ViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRootViewController.h"

@import MapKit;

#import "GBAboutController.h"
#import "GBRequestHandler.h"
#import "XMLReader.h"
#import "GBRoute.h"
#import "GBBusAnnotation.h"
#import "GBBusStopAnnotation.h"
#import "GBBusRouteLine.h"
#import "GBColors.h"
#import "GBMapHandler.h"
#import "MFSideMenu.h"
#import "GBConstants.h"
#import "GBUserInterface.h"
#import "GBBusRouteControlView.h"

NSString * const GBRootViewControllerTitle = @"GT Buses";
int const kMaxNumPredictions = 3;
float const kSetRegionAnimationSpeed = 0.4f;

@interface GBRootViewController () <RequestHandlerDelegate, CLLocationManagerDelegate> {
    NSTimer *refreshTimer;
    
    long long lastLocationUpdate;
    long long lastPredictionUpdate;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) GBBusRouteControlView *busRouteControlView;
@property (nonatomic, strong) GBMapHandler *mapHandler;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) NSMutableArray *routes;

@end

@implementation GBRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationController.navigationBar.topItem.title = GBRootViewControllerTitle;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIColor *color = [UIColor appTintColor];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = color;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        self.navigationController.navigationBar.tintColor = color;
    }
    UIColor *tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : color;
    self.navigationItem.leftBarButtonItem.tintColor = tintColor;
    self.navigationItem.rightBarButtonItem.tintColor = tintColor;
    _busRouteControlView.busRouteControl.tintColor = tintColor;
    _busRouteControlView.backgroundColor = color;
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
    aboutButton.tintColor = tintColor;
    self.navigationItem.leftBarButtonItem = aboutButton;
    
//    UIImage *faceImage = [UIImage imageNamed:@"List.png"];
//    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
//    face.bounds = CGRectMake(0, 0, faceImage.size.width/2, faceImage.size.height/2);
//    [face setImage:faceImage forState:UIControlStateNormal];
    
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithCustomView:face];
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"List.png"] style:UIBarButtonItemStylePlain target:self action:nil];
//    listButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : [Colors appTintColor];
//    self.navigationItem.rightBarButtonItem = listButton;
    
    _busRouteControlView = [[GBBusRouteControlView alloc] init];
    [_busRouteControlView.busRouteControl addTarget:self action:@selector(didChangeBusRoute) forControlEvents:UIControlEventValueChanged];
    
    _mapView = [[MKMapView alloc] init];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    if ([_mapView respondsToSelector:@selector(setRotateEnabled:)]) _mapView.rotateEnabled = NO;
    
    _mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775978, -84.399269), MKCoordinateSpanMake(0.025059, 0.023190));
    [self.view addSubview:_mapView];
    [self.view addSubview:_busRouteControlView];
    
    _mapHandler = [[GBMapHandler alloc] init];
    _mapView.delegate = _mapHandler;
    
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_mapView]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_mapView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_busRouteControlView]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_busRouteControlView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_busRouteControlView(controlViewHeight)][_mapView]|"
                                      options:0
                                      metrics:@{@"controlViewHeight":@40}
                                      views:NSDictionaryOfVariableBindings(_busRouteControlView, _mapView)]];
    [self.view addConstraints:constraints];
    
    _routes = [NSMutableArray new];
    
    self.menuContainerViewController.menuWidth = (IS_IPAD) ? 200 : 150;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateEventOccurred:) name:MFSideMenuStateNotificationEvent object:nil];
    
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
    if (refreshTimer) [refreshTimer invalidate];
    [_mapView setShowsUserLocation:NO];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [_mapView setShowsUserLocation:YES];
    
    [self updateVehicleLocations];
    if (!refreshTimer.isValid)
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateVehicleLocations) userInfo:nil repeats:YES];
}

- (void)aboutPressed {
    if (self.menuContainerViewController.menuState == MFSideMenuStateClosed)
        [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:NULL];
    else
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:NULL];
}

#pragma mark Request Handler Delegate

- (void)handleResponse:(RequestHandler *)handler data:(id)data {
    [_busRouteControlView.activityIndicator stopAnimating];
    
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error) {
        self.navigationItem.rightBarButtonItem = nil;
        _busRouteControlView.errorLabel.hidden = YES;
        _busRouteControlView.busRouteControl.hidden = NO;
        
        if ([handler.task isEqualToString:@"routeConfig"]) {
            if (_busRouteControlView.busRouteControl.numberOfSegments == 0) {
                NSArray *newRoutes = dictionary[@"body"][@"route"];
                
                for (NSDictionary *dictionary in newRoutes) {
                    GBRoute *route = [dictionary toRoute];
                    [_routes addObject:route];
                    NSInteger index = _busRouteControlView.busRouteControl.numberOfSegments;
                    [_busRouteControlView.busRouteControl insertSegmentWithTitle:route.title atIndex:index animated:YES];
                }
                
                NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsKeySelectedRoute];
                if (_busRouteControlView.busRouteControl.numberOfSegments)
                    _busRouteControlView.busRouteControl.selectedSegmentIndex = (index < _busRouteControlView.busRouteControl.numberOfSegments) ? index : 0;
                
                [self didChangeBusRoute];
            }
        } else if ([handler.task isEqualToString:@"vehicleLocations"]) {
            long long newLocationUpdate = [dictionary[@"body"][@"lastTime"][@"time"] longLongValue];
            
            if (newLocationUpdate != lastLocationUpdate) {
                NSArray *vehicles = dictionary[@"body"][@"vehicle"];
                
                if (vehicles) {
                    if (![vehicles isKindOfClass:[NSArray class]])
                        vehicles = [NSArray arrayWithObject:vehicles];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@",[GBBusAnnotation class]];
                    NSMutableArray *busAnnotations = [[_mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    GBRoute *selectedRoute = [self selectedRoute];
                    
                    for (NSDictionary *busPosition in vehicles) {
                        GBBusAnnotation *annotation = [[GBBusAnnotation alloc] init];
                        annotation.busIdentifier = busPosition[@"id"];
                        annotation.color = [selectedRoute.color darkerColor:0.5];
                        
                        BOOL found = NO;
                        for (int x = 0; x < [busAnnotations count]; x++) {
                            GBBusAnnotation *busAnnotation = busAnnotations[x];
                            if ([busAnnotation isEqual:annotation]) {
                                [busAnnotations removeObject:busAnnotation];
                                annotation = busAnnotation;
                                found = YES;
                                break;
                            }
                        }
                        
                        annotation.heading = [busPosition[@"heading"] intValue];
                        
                        if (annotation.coordinate.latitude != [busPosition[@"lat"] doubleValue] || annotation.coordinate.longitude != [busPosition[@"lon"] doubleValue]) {
                            [UIView animateWithDuration:1 animations:^{
                                [annotation updateHeading];
                                [annotation setCoordinate:CLLocationCoordinate2DMake([busPosition[@"lat"] doubleValue], [busPosition[@"lon"] doubleValue])];
                            }];
                        }
                        
                        if (!found && [selectedRoute.tag isEqualToString:busPosition[@"routeTag"]])
                            [_mapView addAnnotation:annotation];
                    }
                    
                    for (GBBusAnnotation *annotation in busAnnotations)
                        [_mapView removeAnnotation:annotation];
                }
            }
            lastLocationUpdate = newLocationUpdate;
        } else if ([handler.task isEqualToString:@"vehiclePredictions"]) {
            long long newPredictionUpdate = [dictionary[@"body"][@"keyForNextTime"][@"value"] longLongValue];
            if (newPredictionUpdate != lastPredictionUpdate) {
                NSArray *predictions = dictionary[@"body"][@"predictions"];
                if (predictions) {
                    if (![predictions isKindOfClass:[NSArray class]])
                        predictions = [NSArray arrayWithObject:predictions];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBBusStopAnnotation class]];
                    NSMutableArray *busStopAnnotations = [[_mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    for (NSDictionary *busStop in predictions) {
                        NSArray *predictionData = busStop[@"direction"][@"prediction"];
                        NSArray *predictions;
                        if (predictionData) {
                            // If object is not array, add it to an array (XML workaround)
                            if (![predictionData isKindOfClass:[NSArray class]])
                                predictionData = [NSArray arrayWithObject:predictionData];
                            
                            // Only show the first three predictions
                            predictions = [predictionData subarrayWithRange:NSMakeRange(0, fmin(kMaxNumPredictions, [predictionData count]))];
                        }
                        
                        NSString *stopTag = busStop[@"stopTag"];
                        for (int x = 0; x < [busStopAnnotations count]; x++) {
                            GBBusStopAnnotation *busStopAnnotation = busStopAnnotations[x];
                            if ([busStopAnnotation.stopTag isEqualToString:stopTag]) {
                                if ([predictions count]) {
                                    NSMutableString *subtitle = [NSMutableString stringWithString:@"Next: "];
                                    for (int x = 0; x < [predictions count]; x++) {
                                        NSDictionary *prediction = predictions[x];
                                        // Don't add comma if it's the last element
                                        [subtitle appendFormat:(x == [predictions count] - 1) ? @"%@" : @"%@, ", prediction[@"minutes"]];
                                    }
                                    busStopAnnotation.subtitle = subtitle;
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
    } else [self handleError:handler code:4923 message:@"Error Parsing Data"];
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    [_busRouteControlView.activityIndicator stopAnimating];
    _busRouteControlView.errorLabel.hidden = NO;
    _busRouteControlView.busRouteControl.hidden = YES;
    
    UIColor *tintColor = [UIColor appTintColor];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateVehicleLocations)];
    refreshButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : tintColor;
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    if (code == 1008 || code == 1009)
        _busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"No Internet Connection (-%i)", code];
    else if (code == 400)
        _busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Bad Request (-%i)", code];
    else if (code == 404)
        _busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Resource Error (-%i)", code];
    else if (code == 500)
        _busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Internal Server Error (-%i)", code];
    else if (code == 503)
        _busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Timed Out (-%i)", code];
    else
        _busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Error Connecting (-%i)", code];
}

- (GBRoute *)selectedRoute {
    NSInteger index = _busRouteControlView.busRouteControl.selectedSegmentIndex;
    return (index != UISegmentedControlNoSegment) ? _routes[index] : nil;
}

- (void)updateVehicleLocations {
    GBRoute *selectedRoute = [self selectedRoute];
    if (selectedRoute) {
        GBRequestHandler *locationHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"vehicleLocations"];
        [locationHandler positionForBus:selectedRoute.tag];
        
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"vehiclePredictions"];
        [predictionHandler predictionsForBus:selectedRoute.tag];
    }
    else {
        GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"routeConfig"];
        [_busRouteControlView.activityIndicator startAnimating];
        _busRouteControlView.errorLabel.hidden = YES;
        [requestHandler routeConfig];
    }
}

- (void)didChangeBusRoute {
    NSInteger index = _busRouteControlView.busRouteControl.selectedSegmentIndex;
    if (index != UISegmentedControlNoSegment)
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:GBUserDefaultsKeySelectedRoute];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
    
    GBRoute *selectedRoute = [self selectedRoute];
    [UIView animateWithDuration:kSetRegionAnimationSpeed animations:^{
        [_mapView setRegion:[_mapView regionThatFits:selectedRoute.region]];
    }];
    
    [self updateVehicleLocations];
    
    for (NSDictionary *path in selectedRoute.paths) {
        NSArray *points = path[@"point"];
        CLLocationCoordinate2D coordinates[[points count]];
        for (int y = 0; y < [points count]; y++) {
            NSDictionary *point = points[y];
            coordinates[y] = CLLocationCoordinate2DMake([point[@"lat"] floatValue], [point[@"lon"] floatValue]);
        }
        GBBusRouteLine *polygon = [GBBusRouteLine polylineWithCoordinates:coordinates count:[points count]];
        polygon.color = selectedRoute.color;
        [_mapView addOverlay:polygon];
    }
    
    for (NSDictionary *stop in selectedRoute.stops) {
        GBBusStopAnnotation *stopPin = [[GBBusStopAnnotation alloc] init];
        stopPin.title = stop[@"title"];
        stopPin.subtitle = @"No Predictions";
        stopPin.tag = selectedRoute.tag;
        stopPin.stopTag = stop[@"tag"];
        stopPin.color = selectedRoute.color;
        [stopPin setCoordinate:CLLocationCoordinate2DMake([stop[@"lat"] doubleValue], [stop[@"lon"] doubleValue])];
        [_mapView addAnnotation:stopPin];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(fixRegion) withObject:nil afterDelay:1];
}

- (void)fixRegion {
    GBRoute *selectedRoute = [self selectedRoute];
    [UIView animateWithDuration:kSetRegionAnimationSpeed animations:^{
        [_mapView setRegion:[_mapView regionThatFits:selectedRoute.region]];
    }];
}

@end
