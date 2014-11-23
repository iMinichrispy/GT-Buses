//
//  GBMapView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBMapViewController.h"

#import "GBMapView.h"
#import "GBBusRouteControlView.h"
#import "GBRequestHandler.h"
#import "GBRoute.h"
#import "GBStop.h"
#import "GBConstants.h"
#import "GBConfig.h"
#import "GBColors.h"
#import "XMLReader.h"
#import "GBBusAnnotation.h"
#import "GBStopAnnotation.h"
#import "GBBusRouteLine.h"
#import "GBBuildingAnnotation.h"
#import "GBBusAnnotationView.h"
#import "GBBus.h"

#if APP_STORE_MAP
#import "MKMapView+AppStoreMap.h"
#endif

float const kSetRegionAnimationSpeed = 0.15f;
int const kRefreshInterval = 5;

@interface GBMapViewController () <RequestHandlerDelegate, CLLocationManagerDelegate> {
    long long lastLocationUpdate;
    long long lastPredictionUpdate;
}

@property (nonatomic, strong) GBBusRouteControlView *busRouteControlView;
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation GBMapViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _mapView = [[GBMapView alloc] init];
        [self.view addSubview:_mapView];
        
        _busRouteControlView = [[GBBusRouteControlView alloc] init];
        [_busRouteControlView.busRouteControl addTarget:self action:@selector(didChangeBusRoute) forControlEvents:UIControlEventValueChanged];
        [_busRouteControlView.refreshButton addTarget:self action:@selector(requestUpdate) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_busRouteControlView];
        
        _routes = [NSMutableArray new];
        
        [self setupConstraints];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePartyMode:) name:GBNotificationPartyModeDidChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)setupConstraints {
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
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_busRouteControlView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_busRouteControlView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_busRouteControlView(controlViewHeight)][contentView]|"
                                      options:0
                                      metrics:@{@"controlViewHeight":@43}
                                      views:NSDictionaryOfVariableBindings(_busRouteControlView, contentView)]];
    [self.view addConstraints:constraints];
}

- (void)updateTintColor:(NSNotification *)notification {
    [_busRouteControlView updateTintColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ROTATION_ENABLED) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(fixRegion) withObject:nil afterDelay:1];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self showUserLocation];
    [self resetRefreshTimer];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self hideUserLocation];
    [self invalidateRefreshTimer];
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

- (void)hideUserLocation {
    _mapView.showsUserLocation = NO;
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
        _busRouteControlView.errorLabel.hidden = YES;
        _busRouteControlView.busRouteControl.hidden = NO;
        _busRouteControlView.refreshButton.hidden = YES;
        
        if (handler.task == GBRequestRouteConfigTask) {
            // Not as big of an issue if predictions or locations fail due to nextbus
            if (![GBRequestHandler isNextBusError:dictionary]) {
                GBRoute *selectedRoute = [self selectedRoute];
                // Prevents duplicate routes from being added to route segmented control in case connection is slow and route config is requested multiple times
                if (!selectedRoute) {
                    NSArray *routes = dictionary[@"body"][@"route"];
                    for (NSDictionary *dictionary in routes) {
                        GBRoute *route = [dictionary xmlToRoute];
                        [_routes addObject:route];
                        NSInteger index = _busRouteControlView.busRouteControl.numberOfSegments;
                        [_busRouteControlView.busRouteControl insertSegmentWithTitle:route.title atIndex:index animated:YES];
                    }
                    
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
                        [shared setObject:routes forKey:GBSharedDefaultsRoutesKey];
                    }
                    
                    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsSelectedRouteKey];
                    if (_busRouteControlView.busRouteControl.numberOfSegments)
                        _busRouteControlView.busRouteControl.selectedSegmentIndex = index < _busRouteControlView.busRouteControl.numberOfSegments ? index : 0;
                    
                    [self didChangeBusRoute];
                }
            } else {
                [self invalidateRefreshTimer];
                NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestNextbusError userInfo:nil];
                [self handleError:handler error:error];
            }
        } else if (handler.task == GBRequestVehicleLocationsTask) {
            [self checkForMessages:dictionary];
            NSDictionary *config = dictionary[@"body"][@"config"];
            [[GBConfig sharedInstance] handleConfig:config];
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
                            GBBusAnnotation *annotation;
                            for (int x = 0; x < [busAnnotations count]; x++) {
                                GBBusAnnotation *busAnnotation = busAnnotations[x];
                                GBBus *bus = busAnnotation.bus;
                                if ([bus.identifier isEqualToString:busPosition[@"id"]]) {
                                    [busAnnotations removeObject:busAnnotation];
                                    annotation = busAnnotation;
                                    break;
                                }
                            }
                            
                            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([busPosition[@"lat"] doubleValue], [busPosition[@"lon"] doubleValue]);
                            
                            if (!annotation) {
                                // Bus annotation was not found on map, so create a new one
                                GBBus *bus = [[GBBus alloc] init];
                                bus.identifier = busPosition[@"id"];
                                bus.color = [selectedRoute.color darkerColor:0.5];
                                
                                annotation = [[GBBusAnnotation alloc] initWithBus:bus];
                                annotation.coordinate = coordinate;
                                [_mapView addAnnotation:annotation];
                            }
                            
                            annotation.bus.heading = [busPosition[@"heading"] intValue];
                            
                            if (annotation.coordinate.latitude != coordinate.latitude || annotation.coordinate.longitude != coordinate.longitude) {
                                GBBusAnnotationView *annotationView = (GBBusAnnotationView *)[_mapView viewForAnnotation:annotation];
                                [UIView animateWithDuration:.8 animations:^{
                                    [annotationView updateArrowImageRotation];
                                    [annotation setCoordinate:coordinate];
                                }];
                            }
                        }
                    }
                    [_mapView removeAnnotations:busAnnotations];
                }
            }
            lastLocationUpdate = newLocationUpdate;
        } else if (handler.task == GBRequestVehiclePredictionsTask) {
            long long newPredictionUpdate = [dictionary[@"body"][@"keyForNextTime"][@"value"] longLongValue];
            if (newPredictionUpdate != lastPredictionUpdate) {
                NSArray *predictions = dictionary[@"body"][@"predictions"];
                if (predictions) {
                    if (![predictions isKindOfClass:[NSArray class]])
                        predictions = [NSArray arrayWithObject:predictions];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBStopAnnotation class]];
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
                            GBStopAnnotation *busStopAnnotation = busStopAnnotations[x];
                            if ([busStopAnnotation.stop.tag isEqualToString:stopTag]) {
                                busStopAnnotation.subtitle = [GBStop predictionsStringForPredictions:predictions];
                                
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
        } else if (handler.task == GBRequestMessagesTask) {
            
            // check message id
        }
    } else  {
        NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestParseError userInfo:nil];
        [self handleError:handler error:error];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    [_busRouteControlView.activityIndicator stopAnimating];
    _busRouteControlView.errorLabel.hidden = NO;
    _busRouteControlView.busRouteControl.hidden = YES;
    _busRouteControlView.refreshButton.hidden = NO;
    _busRouteControlView.errorLabel.text = [GBRequestHandler errorStringForCode:[error code]];
}

- (GBRoute *)selectedRoute {
    NSInteger index = _busRouteControlView.busRouteControl.selectedSegmentIndex;
    return index != UISegmentedControlNoSegment ? _routes[index] : nil;
}

- (void)requestUpdate {
    GBRoute *selectedRoute = [self selectedRoute];
    if (selectedRoute) {
#if APP_STORE_MAP
        [_mapView showBusesWithRoute:selectedRoute];
        [self invalidateRefreshTimer];
#else
        GBRequestHandler *locationHandler = [[GBRequestHandler alloc] initWithTask:GBRequestVehicleLocationsTask delegate:self];
        [locationHandler locationsForRoute:selectedRoute.tag];
        
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBRequestVehiclePredictionsTask delegate:self];
        [predictionHandler predictionsForRoute:selectedRoute.tag];
#endif
    }
#if !DEFAULT_IMAGE
    else {
        [_busRouteControlView.activityIndicator startAnimating];
        _busRouteControlView.errorLabel.hidden = YES;
        _busRouteControlView.refreshButton.hidden = YES;
        
        GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBRequestRouteConfigTask delegate:self];
        [requestHandler routeConfig];
    }
#endif
}

- (void)didChangeBusRoute {
    [self invalidateRefreshTimer];
    
    NSInteger index = _busRouteControlView.busRouteControl.selectedSegmentIndex;
    if (index != UISegmentedControlNoSegment) {
        [[NSUserDefaults standardUserDefaults] setInteger:index forKey:GBUserDefaultsSelectedRouteKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Don't remove the building annotations
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"not class == %@", [GBBuildingAnnotation class]];
    NSArray *annotations = [_mapView.annotations filteredArrayUsingPredicate:predicate];
    
    [_mapView removeAnnotations:annotations];
    [_mapView removeOverlays:_mapView.overlays];
    
    GBRoute *selectedRoute = [self selectedRoute];
    [UIView animateWithDuration:kSetRegionAnimationSpeed animations:^{
        [_mapView setRegion:[_mapView regionThatFits:selectedRoute.region]];
    }];
    
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
    
    for (GBStop *stop in selectedRoute.stops) {
        GBStopAnnotation *stopAnnotation = [[GBStopAnnotation alloc] initWithStop:stop];
#if DEBUG
        stopAnnotation.title = FORMAT(@"%@ (%@)", stop.title, stop.tag);
#else
        stopAnnotation.title = stop.title;
#endif
        stopAnnotation.subtitle = NSLocalizedString(@"NO_PREDICTIONS", @"No predictions for stop");
        [stopAnnotation setCoordinate:CLLocationCoordinate2DMake(stop.lat, stop.lon)];
        [_mapView addAnnotation:stopAnnotation];
#if APP_STORE_MAP
        stopAnnotation.subtitle = [MKMapView predictionsStringForRoute:selectedRoute];
        NSString *selectedStopTag = [MKMapView selectedStopTagForRoute:selectedRoute];
        if ([stopAnnotation.stop.tag isEqualToString:selectedStopTag])
            [_mapView selectAnnotation:stopAnnotation animated:YES];
#endif
    }
    
    [self resetRefreshTimer];
}

- (void)fixRegion {
    GBRoute *selectedRoute = [self selectedRoute];
    [UIView animateWithDuration:kSetRegionAnimationSpeed animations:^{
        [_mapView setRegion:[_mapView regionThatFits:selectedRoute.region]];
    }];
}

- (void)togglePartyMode:(NSNotification *)notification {
    // Refreshes route config
    [_busRouteControlView.busRouteControl removeAllSegments];
    [self invalidateRefreshTimer];
    [self requestUpdate];
    
    BOOL party = [[GBConfig sharedInstance] isParty];
    if (!party) {
        [GBColors setAppTintColor:[GBColors defaultColor]];
    }
}

#if DEBUG
- (void)resetBackend {
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:nil delegate:nil];
    [requestHandler resetBackend];
}

- (void)updateStops {
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:nil delegate:nil];
    [requestHandler updateStops];
}

- (void)toggleParty {
    GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:nil delegate:nil];
    [requestHandler toggleParty];
}
#endif

#pragma mark - Messages

- (void)checkForMessages:(NSDictionary *)dictionary {
    /*
     NSDictionary *prediction = [dictionary[@"body"][@"predictions"] firstObject];
     if (prediction) {
     NSString *messageText = prediction[@"message"][@"text"];
     if ([messageText length]) {
     GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithTask:GBMessagesTask delegate:self];
     [requestHandler messages];
     }
     }*/
}

#pragma mark - Timer

- (void)resetRefreshTimer {
    if (![_refreshTimer isValid])
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(requestUpdate) userInfo:nil repeats:YES];
    _refreshTimer.tolerance = 1; // Improves power efficiency
    [self requestUpdate];
}

- (void)invalidateRefreshTimer {
    if ([_refreshTimer isValid]) [_refreshTimer invalidate];
}

@end
