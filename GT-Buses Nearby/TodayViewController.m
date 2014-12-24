//
//  TodayViewController.m
//  GT-Buses Nearby
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "TodayViewController.h"

#import "GBStopGroup.h"
#import "GBDirection.h"

@import NotificationCenter;
@import CoreLocation;

@interface TodayViewController () <NCWidgetProviding, CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *savedRoutes;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation TodayViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sectionView = [[GBSectionView alloc] initWithTitle:NSLocalizedString(@"NEARBY_SECTION", @"Nearby section title") defaultsKey:@"key11"];
        
        NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
        NSArray *routes = [[NSUserDefaults sharedDefaults] objectForKey:GBSharedDefaultsRoutesKey];
        NSMutableArray *disabledRoutes = [[sharedDefaults objectForKey:GBSharedDefaultsDisabledRoutesKey] mutableCopy];
        
        NSMutableArray *savedRoutes = [NSMutableArray new];
        if ([routes count]) {
            for (NSDictionary *routeDic in routes) {
                GBRoute *route = [routeDic xmlToRoute];
                
                // Ensure only enabled routes are used
                BOOL enabled = YES;
                for (int x = 0; x < [disabledRoutes count]; x++) {
                    NSDictionary *dictionary = disabledRoutes[x];
                    if ([dictionary[@"tag"] isEqualToString:route.tag]) {
                        [disabledRoutes removeObjectAtIndex:x];
                        enabled = NO;
                        break;
                    }
                }
                
                if (enabled) {
                    [savedRoutes addObject:route];
                }
            }
        }
        _savedRoutes = savedRoutes;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 40.0f; // Min meters required for location update
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupForUserLocation];
}

- (void)insertStopGroup:(GBStopGroup *)newStopGroup inNearestStops:(NSMutableArray *)nearestStops withDistance:(CLLocationDistance)distance {
    newStopGroup.distance = distance;
    int index = 0;
    for (GBStopGroup *stopGroup in nearestStops) {
        if (stopGroup.distance > newStopGroup.distance) {
            break;
        }
        index++;
    }
    [nearestStops insertObject:newStopGroup atIndex:index];
}

- (void)updateLayout {
    CLLocation *location = _locationManager.location;
    if (location) {
        if ([_savedRoutes count]) {
            NSMutableArray *newNearestStops = [NSMutableArray new];
            for (GBRoute *route in _savedRoutes) {
                for (GBStop *stop in route.stops) {
                    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:stop.lat longitude:stop.lon];
                    CLLocationDistance distance = [location distanceFromLocation:stopLocation]; //meters (double)
                    
                    GBStopGroup *newStopGroup = [[GBStopGroup alloc] initWithStop:stop];
                    NSInteger index = [newNearestStops indexOfObject:newStopGroup];
                    
                    if (index == NSNotFound) {
                        [self insertStopGroup:newStopGroup inNearestStops:newNearestStops withDistance:distance];
                    } else {
#warning untested if actually works
                        if (newStopGroup.firstStop.direction.isOneDirection) {
                            // create new stop group
                            [self insertStopGroup:newStopGroup inNearestStops:newNearestStops withDistance:distance];
                        } else {
                            GBStopGroup *existingGroup = newNearestStops[index];
                            [existingGroup addStop:stop];
                        }
                    }
                }
            }
            
            if ([newNearestStops count]) {
                if (![newNearestStops isEqualToArray:self.stops]) {
                    self.stops = newNearestStops;
                    self.sectionView.parameterString = nil;
                    NSMutableArray *stopViews = [NSMutableArray new];
                    
                    NSMutableArray *constraints = [NSMutableArray new];
                    [self.sectionView reset];
                    
                    for (int x = 0; x < [self.stops count] && x < [self maxNumberStops]; x++) {
                        GBStopGroup *stopGroup = self.stops[x];
                        
                        GBStopView *stopView = [[GBStopView alloc] initWithStopGroup:stopGroup];
                        [self.sectionView.stopsView addSubview:stopView];
                        [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:stopView horizontal:YES]];
                        [stopViews addObject:stopView];
                        
                        [self.sectionView addParametersForStopGroup:stopGroup];
                    }
                    
                    
                    for (int i = 1; i < [stopViews count]; ++i) {
                        [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromTopView:stopViews[i - 1] toBottomView:stopViews[i] spacing:4.0]];
                    }
                    
                    GBStopView *first = [stopViews firstObject];
                    GBStopView *last = [stopViews lastObject];
                    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
                    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
                    [NSLayoutConstraint activateConstraints:constraints];
                }
            } else {
                [self.sectionView reset];
                [self displayError:NSLocalizedString(@"NO_NEARBY_STOPS", @"No nearby stops")];
            }
        } else {
            [self.sectionView reset];
            // request route config
            [self displayError:NSLocalizedString(@"NO_ROUTE_CONFIG", @"No route config")];
        }
    } else {
        [self.sectionView reset];
        [self displayError:NSLocalizedString(@"NO_LOCATION_DATA", @"No location data")];
    }
    [self updatePredictions];
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self updateLayout];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self setupForUserLocation];
}

- (void)setupForUserLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [self.sectionView reset];
            [self displayError:NSLocalizedString(@"LOCATION_SERVICES_DISABLED", @"Location sevices are disabled")];
            [_locationManager requestWhenInUseAuthorization];
        } else if (status == kCLAuthorizationStatusDenied) {
            [self.sectionView reset];
            [self displayError:NSLocalizedString(@"LOCATION_SERVICES_DISABLED", @"Location sevices are disabled")];
        } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            [_locationManager startUpdatingLocation];
            [self updateLayout];
        }
    } else {
        [self.sectionView reset];
        [self displayError:NSLocalizedString(@"LOCATION_SERVICES_DISABLED", @"Location sevices are disabled")];
    }
}

@end
