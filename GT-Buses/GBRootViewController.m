//
//  GBViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRootViewController.h"

@import MapKit;

#import "GBAboutController.h"
#import "GBRequestHandler.h"
#import "GBRoute.h"
#import "GBBusAnnotation.h"
#import "GBBusStopAnnotation.h"
#import "GBBusRouteLine.h"
#import "GBColors.h"
#import "GBMapHandler.h"
#import "GBConstants.h"
#import "GBUserInterface.h"
#import "GBBusRouteControlView.h"
#import "XMLReader.h"
#import "MFSideMenu.h"
#import "GBConfig.h"

#if APP_STORE_MAP
#import "MKMapView+AppStoreMap.h"
#endif

#define DEFAULT_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775978, -84.399269), MKCoordinateSpanMake(0.025059, 0.023190))

static NSString * const GBRouteConfigTask = @"GBRouteConfigTask";
static NSString * const GBVehicleLocationsTask = @"GBVehicleLocationsTask";
static NSString * const GBVehiclePredictionsTask = @"GBVehiclePredictionsTask";

float const kSetRegionAnimationSpeed = 0.4f;
int const kRefreshInterval = 5;

@interface GBRootViewController () <RequestHandlerDelegate, CLLocationManagerDelegate> {
    NSTimer *refreshTimer;
    
    long long lastLocationUpdate;
    long long lastPredictionUpdate;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) GBBusRouteControlView *busRouteControlView;
@property (nonatomic, strong) GBMapHandler *mapHandler;
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation GBRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuContainerViewController.menuWidth = IS_IPAD ? kSideWidthiPad : kSideWidth;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateEventOccurred:) name:MFSideMenuStateNotificationEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePartyMode:) name:GBNotificationPartyModeDidChange object:nil];
    
    self.title = @"GT Buses";
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
    aboutButton.tintColor = [UIColor controlTintColor];
    self.navigationItem.leftBarButtonItem = aboutButton;
    
    _busRouteControlView = [[GBBusRouteControlView alloc] init];
    [_busRouteControlView.busRouteControl addTarget:self action:@selector(didChangeBusRoute) forControlEvents:UIControlEventValueChanged];
    
    _mapView = [[MKMapView alloc] init];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    if ([_mapView respondsToSelector:@selector(setRotateEnabled:)]) _mapView.rotateEnabled = NO;
    
    _mapView.region = DEFAULT_REGION;
    [self.view addSubview:_mapView];
    [self.view addSubview:_busRouteControlView];
    
    _mapHandler = [[GBMapHandler alloc] init];
    _mapView.delegate = _mapHandler;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [self showUserLocation];
    
#if DEFAULT_IMAGE
    self.title = @"";
    self.navigationItem.leftBarButtonItem = nil;
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = RGBColor(240, 235, 212);
    [self.view addSubview:contentView];
#else
    UIView *contentView = _mapView;
#endif
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[contentView]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(contentView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_busRouteControlView]|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(_busRouteControlView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_busRouteControlView(controlViewHeight)][contentView]|"
                                      options:0
                                      metrics:@{@"controlViewHeight":@43}
                                      views:NSDictionaryOfVariableBindings(_busRouteControlView, contentView)]];
    [self.view addConstraints:constraints];
    
#if DEBUG
    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetBackend:)];
    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *partyItem = [[UIBarButtonItem alloc] initWithTitle:@"Party" style:UIBarButtonItemStylePlain target:self action:@selector(toggleParty:)];
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *updateStopsItem = [[UIBarButtonItem alloc] initWithTitle:@"Update Stops" style:UIBarButtonItemStylePlain target:self action:@selector(updateStops:)];
    self.toolbarItems = @[resetItem, flexibleSpace1, partyItem, flexibleSpace2, updateStopsItem];
    
    UIColor *tintColor = [UIColor appTintColor];
    if ([self.navigationController.toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.toolbar.barTintColor = tintColor;
        self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.toolbar.tintColor = tintColor;
    }
#endif
    
    _routes = [NSMutableArray new];
}

- (void)updateTintColor:(NSNotification *)notification {
    [(GBNavigationController *)self.navigationController updateTintColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor controlTintColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor controlTintColor];
    [_busRouteControlView updateTintColor];
#if DEBUG
    UIColor *tintColor = notification.object;
    if ([self.navigationController.toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.toolbar.barTintColor = tintColor;
        self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.toolbar.tintColor = tintColor;
    }
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IS_IPAD) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuPanMode panMode = self.menuContainerViewController.menuState == MFSideMenuStateClosed ?  MFSideMenuPanModeNone: MFSideMenuPanModeCenterViewController;
    self.menuContainerViewController.panMode = panMode;
}

- (void)aboutPressed {
    MFSideMenuState state = self.menuContainerViewController.menuState == MFSideMenuStateClosed ? MFSideMenuStateLeftMenuOpen : MFSideMenuStateClosed;
    [self.menuContainerViewController setMenuState:state completion:NULL];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self showUserLocation];
    [self updateVehicleLocations];
    
    if (![refreshTimer isValid])
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(updateVehicleLocations) userInfo:nil repeats:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if ([refreshTimer isValid]) [refreshTimer invalidate];
    _mapView.showsUserLocation = NO;
}

#pragma mark - Location Manager

- (void)showUserLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
        else
            _mapView.showsUserLocation = YES;
    } else
        _mapView.showsUserLocation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) _mapView.showsUserLocation = YES;
}

#pragma mark - Request Handler Delegate

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    [_busRouteControlView.activityIndicator stopAnimating];
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error && dictionary) {
        self.navigationItem.rightBarButtonItem = nil;
        _busRouteControlView.errorLabel.hidden = YES;
        _busRouteControlView.busRouteControl.hidden = NO;
        
        if (handler.task == GBRouteConfigTask) {
            NSArray *newRoutes = dictionary[@"body"][@"route"];
            GBRoute *selectedRoute = [self selectedRoute];
            // Prevents duplicate routes from being added to route segmented control in case connection is slow and route config is requested multiple times
            if (!selectedRoute) {
                for (NSDictionary *dictionary in newRoutes) {
                    GBRoute *route = [dictionary toRoute];
                    [_routes addObject:route];
                    NSInteger index = _busRouteControlView.busRouteControl.numberOfSegments;
                    [_busRouteControlView.busRouteControl insertSegmentWithTitle:route.title atIndex:index animated:YES];
                }
                
                NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsKeySelectedRoute];
                if (_busRouteControlView.busRouteControl.numberOfSegments)
                    _busRouteControlView.busRouteControl.selectedSegmentIndex = index < _busRouteControlView.busRouteControl.numberOfSegments ? index : 0;
                
                [self didChangeBusRoute];
            }
        } else if (handler.task == GBVehicleLocationsTask) {
            long long newLocationUpdate = [dictionary[@"body"][@"lastTime"][@"time"] longLongValue];
            if (newLocationUpdate != lastLocationUpdate) {
                NSArray *vehicles = dictionary[@"body"][@"vehicle"];
                if (vehicles) {
                    if (![vehicles isKindOfClass:[NSArray class]]) vehicles = @[vehicles];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBBusAnnotation class]];
                    NSMutableArray *busAnnotations = [[_mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    GBRoute *selectedRoute = [self selectedRoute];
                    
                    for (NSDictionary *busPosition in vehicles) {
                        // This if check ensures that when the user switches to a new route, no new buses from the old route are added and all buses not belonging to the current route are removed
                        if ([selectedRoute.tag isEqualToString:busPosition[@"routeTag"]]) {
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
                                    [annotation updateArrowImageRotation];
                                    [annotation setCoordinate:CLLocationCoordinate2DMake([busPosition[@"lat"] doubleValue], [busPosition[@"lon"] doubleValue])];
                                }];
                            }
                            
                            if (!found) [_mapView addAnnotation:annotation];
                        }
                    }
                    [_mapView removeAnnotations:busAnnotations];
                }
            }
            lastLocationUpdate = newLocationUpdate;
        } else if (handler.task == GBVehiclePredictionsTask) {
            NSDictionary *config = dictionary[@"body"][@"config"];
            [[GBConfig sharedInstance] handleConfig:config];
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
                                predictionData = @[predictionData];
                            
                            // Only show the first three predictions
                            predictions = [predictionData subarrayWithRange:NSMakeRange(0, MIN(3, [predictionData count]))];
                        }
                        
                        NSString *stopTag = busStop[@"stopTag"];
                        for (int x = 0; x < [busStopAnnotations count]; x++) {
                            GBBusStopAnnotation *busStopAnnotation = busStopAnnotations[x];
                            if ([busStopAnnotation.stopTag isEqualToString:stopTag]) {
                                if ([predictions count]) {
                                    NSMutableString *subtitle = [NSMutableString stringWithString:@"Next: "];
                                    
                                    NSDictionary *lastPredication = [predictions lastObject];
                                    for (NSDictionary *prediction in predictions) {
#if DEBUG
                                        int totalSeconds = [prediction[@"seconds"] intValue];
                                        double minutes = totalSeconds / 60;
                                        double seconds = totalSeconds % 60;
                                        NSString *time = FORMAT(@"%.f:%02.f", minutes, seconds);
                                        [subtitle appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", time];
#else
                                        [subtitle appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
#endif
                                    }
                                    busStopAnnotation.subtitle = subtitle;
                                }
                                else busStopAnnotation.subtitle = @"No Predictions";
                                
                                // It's okay to remove an element while iterating since we're breaking anyway
                                // Using a double for loop so this alows us to iterate over fewer elements the next time
                                [busStopAnnotations removeObject:busStopAnnotation];
                                break;
                            }
                        }
                    }
                }
            }
            lastPredictionUpdate = newPredictionUpdate;
        }
    } else [self handleError:handler code:2923 message:@"Parsing Error"];
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    [_busRouteControlView.activityIndicator stopAnimating];
    _busRouteControlView.errorLabel.hidden = NO;
    _busRouteControlView.busRouteControl.hidden = YES;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateVehicleLocations)];
    refreshButton.tintColor = [UIColor controlTintColor];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    NSString *errorString;
    switch (code) {
        case 400: errorString = @"Bad Request"; break;
        case 404: errorString = @"Resource Error"; break;
        case 500: errorString = @"Internal Server Error"; break;
        case 503: errorString = @"Timed Out"; break;
        case 1008: case 1009: errorString = @"No Internet Connection"; break;
        case 2923: errorString = @"Parsing Error"; break;
        default: errorString = @"Error Connecting"; break;
    }
    _busRouteControlView.errorLabel.text = FORMAT(@"%@ (-%li)", errorString, (long)code);
}

- (GBRoute *)selectedRoute {
    NSInteger index = _busRouteControlView.busRouteControl.selectedSegmentIndex;
    return index != UISegmentedControlNoSegment ? _routes[index] : nil;
}

- (void)updateVehicleLocations {
    GBRoute *selectedRoute = [self selectedRoute];
    if (selectedRoute) {
#if APP_STORE_MAP
        [_mapView showBusesWithRoute:selectedRoute];
        if ([refreshTimer isValid]) [refreshTimer invalidate];
#else
        GBRequestHandler *locationHandler = [[GBRequestHandler alloc] initWithTask:GBVehicleLocationsTask delegate:self];
        [locationHandler locationsForRoute:selectedRoute.tag];
        
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBVehiclePredictionsTask delegate:self];
        [predictionHandler predictionsForRoute:selectedRoute.tag];
#endif
    }
#if !DEFAULT_IMAGE
    else {
        [_busRouteControlView.activityIndicator startAnimating];
        _busRouteControlView.errorLabel.hidden = YES;
        
        GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRouteConfigTask delegate:self];
        [requestHandler routeConfig];
    }
#endif
}

- (void)didChangeBusRoute {
    if ([refreshTimer isValid]) [refreshTimer invalidate];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(updateVehicleLocations) userInfo:nil repeats:YES];
    
    NSInteger index = _busRouteControlView.busRouteControl.selectedSegmentIndex;
    if (index != UISegmentedControlNoSegment) {
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:GBUserDefaultsKeySelectedRoute];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
    
    GBRoute *selectedRoute = [self selectedRoute];
    [UIView animateWithDuration:kSetRegionAnimationSpeed animations:^{
        [_mapView setRegion:[_mapView regionThatFits:selectedRoute.region]];
    }];
    
    [self updateVehicleLocations];
    
    if ([[GBConfig sharedInstance] isParty]) {
        [GBColors setAppTintColor:selectedRoute.color];
    }
    
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
#if DEBUG
        stopPin.title = FORMAT(@"%@ (%@)", stop[@"title"], stop[@"tag"]);
#else
        stopPin.title = stop[@"title"];
#endif
        stopPin.subtitle = @"No Predictions";
        stopPin.tag = selectedRoute.tag;
        stopPin.stopTag = stop[@"tag"];
        stopPin.color = selectedRoute.color;
        [stopPin setCoordinate:CLLocationCoordinate2DMake([stop[@"lat"] doubleValue], [stop[@"lon"] doubleValue])];
        [_mapView addAnnotation:stopPin];
#if APP_STORE_MAP
        stopPin.subtitle = [MKMapView predictionsStringForRoute:selectedRoute];
        NSString *selectedStopTag = [MKMapView selectedStopTagForRoute:selectedRoute];
        if ([stopPin.stopTag isEqualToString:selectedStopTag])
            [_mapView selectAnnotation:stopPin animated:YES];
#endif
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

- (void)togglePartyMode:(NSNotification *)notification {
    BOOL party = [[GBConfig sharedInstance] isParty];
    [self didChangeBusRoute];
    if (party) {
        GBRoute *selectedRoute = [self selectedRoute];
        [GBColors setAppTintColor:selectedRoute.color];
    } else {
        [GBColors setAppTintColor:[GBColors defaultColor]];
    }
}

#if DEBUG
- (void)resetBackend:(UIBarButtonItem *)barItem {
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:nil delegate:nil];
    [requestHandler resetBackend];
}

- (void)updateStops:(UIBarButtonItem *)barItem {
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:nil delegate:nil];
    [requestHandler updateStops];
}

- (void)toggleParty:(UIBarButtonItem *)barItem {
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:nil delegate:nil];
    [requestHandler toggleParty];
}
#endif

@end
