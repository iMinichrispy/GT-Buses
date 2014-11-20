//
//  GBMapViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBMapViewController.h"

@import MapKit;

#import "GBBusRouteControlView.h"
#import "GBMapHandler.h"
#import "GBRequestHandler.h"

#if APP_STORE_MAP
#import "MKMapView+AppStoreMap.h"
#endif

#define DEFAULT_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775978, -84.399269), MKCoordinateSpanMake(0.025059, 0.023190))

float const kSetRegionAnimationSpeed = 0.15f;
int const kRefreshInterval = 5;

@interface GBMapViewController () <RequestHandlerDelegate, CLLocationManagerDelegate> {
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

@implementation GBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    
}

@end
