//
//  TodayViewController.m
//  GT-Buses Extension
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "TodayViewController.h"

#import "GBConstants.h"
#import "GBStopView.h"
#import "GBStop.h"
#import "GBRequestHandler.h"
#import "XMLReader.h"
#import "GBSectionHeaderView.h"
#import "GBConstraintHelper.h"
#import "GBSectionView.h"
#import "GBDirection.h"
#import "GBRoute.h"
#import "GBStopGroup.h"
#import "GBErrorView.h"

@import NotificationCenter;
@import CoreLocation;

@interface TodayViewController () <NCWidgetProviding, RequestHandlerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *savedRoutes;
@property (nonatomic, strong) NSArray *favoriteStops;
@property (nonatomic, strong) NSArray *nearestStops;

@property (nonatomic, strong) NSLayoutConstraint *favoritesHeightConstraint;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) GBSectionView *favoritesSectionView;
@property (nonatomic, strong) GBSectionView *nearbySectionView;

@property (nonatomic) BOOL showFavorites;

@end

@implementation TodayViewController

static NSString * const GBMultiPredictionsTask = @"GBMultiPredictionsTask";
static NSString * const GBFavoritesHeaderTitle = @"Favorites:";
static NSString * const GBNearbyHeaderTitle = @"Nearby:";

int kNumberOfNearbyStopView = 5;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _showFavorites = YES; // load from nsuserdefaults
        
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
        _favoriteStops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
        NSArray *routes = [shared objectForKey:GBSharedDefaultsRoutesKey];
        
        NSMutableArray *savedRoutes = [NSMutableArray new];
        if ([routes count]) {
            for (NSDictionary *routeDic in routes) {
                GBRoute *route = [routeDic xmlToRoute];
                [savedRoutes addObject:route];
            }
        }
        _savedRoutes = savedRoutes;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateLayout {
    NSMutableArray *constraints = [NSMutableArray new];
    
    if (_showFavorites) {
//        if (_favoritesHeightConstraint) {
//            [NSLayoutConstraint deactivateConstraints:@[_favoritesHeightConstraint]];
//        }
        if ([_favoriteStops count]) {
            NSMutableArray *stopViews = [NSMutableArray new];
            for (NSDictionary *dictionary in _favoriteStops) {
                GBStop *stop = [dictionary toStop];
                // need to remove no favorites added view
                
                GBStopView *stopView = [[GBStopView alloc] initWithStop:stop];
                [_favoritesSectionView.stopsView addSubview:stopView];
                [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:stopView horizontal:YES]];
                [stopViews addObject:stopView];
                
                [_favoritesSectionView addParameterForStop:stop];
            }
            
            for (int i = 1; i < [stopViews count]; ++i) {
                [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromTopView:stopViews[i - 1] toBottomView:stopViews[i]]];
            }
            
            GBStopView *first = [stopViews firstObject];
            GBStopView *last = [stopViews lastObject];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
        } else {
            GBErrorView *errorView = [[GBErrorView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
            errorView.label.text = @"No favorites added.";
            
            [_favoritesSectionView.stopsView addSubview:errorView];
            
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:YES]];
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:NO]];
        }
    } else {
        for (UIView *view in _favoritesSectionView.stopsView.subviews) {
            [view removeFromSuperview];
        }
        
//        _favoritesHeightConstraint = [NSLayoutConstraint
//                                      constraintWithItem:_favoritesSectionView.stopsView
//                                      attribute:NSLayoutAttributeHeight
//                                      relatedBy:NSLayoutRelationEqual
//                                      toItem:0
//                                      attribute:0
//                                      multiplier:1
//                                      constant:0];
//        [NSLayoutConstraint activateConstraints:@[_favoritesHeightConstraint]];
    }
    
    
    
    [NSLayoutConstraint activateConstraints:constraints];
    [self updatePredictions];
}

- (void)toggleFavorites:(id)sender {
    _showFavorites = !_showFavorites;
    [self updateLayout];
    NSLog(@"toggle favorites");
}

- (void)toggleNearby:(id)sender {
    NSLog(@"toggleNearby");
}

- (void)updateNearbyLayout {
    CLLocation *location = _locationManager.location;
    if (location) {
        if ([_savedRoutes count]) {
            [_nearbySectionView reset];
            NSMutableArray *newNearestStops = [NSMutableArray new];
            for (GBRoute *route in _savedRoutes) {
                for (GBStop *stop in route.stops) {
                    CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:stop.lat longitude:stop.lon];
                    CLLocationDistance distance = [location distanceFromLocation:stopLocation]; //meters (double)
                    
                    GBStopGroup *newStopGroup = [[GBStopGroup alloc] initWithStop:stop];
                    NSInteger index = [newNearestStops indexOfObject:newStopGroup];
                    if (index == NSNotFound) {
                        newStopGroup.distance = distance;
                        int index = 0;
                        for (GBStopGroup *stopGroup in newNearestStops) {
                            if (stopGroup.distance > newStopGroup.distance) {
                                break;
                            }
                            index++;
                        }
                        [newNearestStops insertObject:newStopGroup atIndex:index];
                    } else {
                        GBStopGroup *existingGroup = newNearestStops[index];
                        [existingGroup addStop:stop];
                    }
                }
            }
            
            if ([newNearestStops count]) {
                if (![newNearestStops isEqualToArray:_nearestStops]) {
                    _nearestStops = newNearestStops;
                    _nearbySectionView.parameterString = nil;
                    NSMutableArray *stopViews = [NSMutableArray new];
                    
                    [_nearbySectionView reset];
                    NSMutableArray *constraints = [NSMutableArray new];
                    
                    for (int x = 0; x < [_nearestStops count] && x < kNumberOfNearbyStopView; x++) {
                        GBStopGroup *stopGroup = _nearestStops[x];
                        
                        GBStopView *stopView = [[GBStopView alloc] initWithStopGroup:stopGroup];
                        [_nearbySectionView.stopsView addSubview:stopView];
                        [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:stopView horizontal:YES]];
                        [stopViews addObject:stopView];
                        
                        [_nearbySectionView addParametersForStopGroup:stopGroup];
                    }
                    
                    
                    for (int i = 1; i < [stopViews count]; ++i) {
                        [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromTopView:stopViews[i - 1] toBottomView:stopViews[i]]];
                    }
                    
                    GBStopView *first = [stopViews firstObject];
                    GBStopView *last = [stopViews lastObject];
                    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
                    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
                    [NSLayoutConstraint activateConstraints:constraints];
                }
            } else {
                [_nearbySectionView reset];
                [self displayError:@"No nearby stops." onView:_nearbySectionView.stopsView];
            }
        } else {
            [_nearbySectionView reset];
            // request route config
            [self displayError:@"No route config." onView:_nearbySectionView.stopsView];
        }
    } else {
        [_nearbySectionView reset];
        [self displayError:@"No location data." onView:_nearbySectionView.stopsView];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self updateNearbyLayout];
}

- (void)setupForUserLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_nearbySectionView reset];
            [self displayError:@"Location services disabled." onView:_nearbySectionView.stopsView];
            [_locationManager requestWhenInUseAuthorization];
        } else if (status == kCLAuthorizationStatusDenied) {
            // minimize nearby section?
            [_nearbySectionView reset];
            [self displayError:@"Location services disabled." onView:_nearbySectionView.stopsView];
        } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            [_locationManager startUpdatingLocation];
            [self updateNearbyLayout];
        }
    } else {
        [_nearbySectionView reset];
        [self displayError:@"Location services disabled." onView:_nearbySectionView.stopsView];
    }
}

- (void)displayError:(NSString *)error onView:(UIView *)view {
    GBErrorView *errorView = [[GBErrorView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
    errorView.label.text = error;
    
    [view addSubview:errorView];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:YES]];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:NO]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self setupForUserLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    _favoritesSectionView = [[GBSectionView alloc] initWithTitle:GBFavoritesHeaderTitle];
    [_favoritesSectionView.headerView addTarget:self action:@selector(toggleFavorites:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_favoritesSectionView];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_favoritesSectionView horizontal:YES]];
    
    _nearbySectionView = [[GBSectionView alloc] initWithTitle:GBNearbyHeaderTitle];
    [_nearbySectionView.headerView addTarget:self action:@selector(toggleNearby:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_nearbySectionView];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_nearbySectionView horizontal:YES]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_favoritesSectionView]-10-[_nearbySectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_favoritesSectionView, _nearbySectionView)]];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 40.0f; // min meters required for location update
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self setupForUserLocation];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    [self updateLayout];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self updatePredictions];
    completionHandler(NCUpdateResultNewData);
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    _favoriteStops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
    _favoritesSectionView.parameterString = nil;
    [self updateLayout];
}

#pragma mark - Request Handler

- (void)updatePredictions {
    NSString *favoritesParameters = _favoritesSectionView.parameterString;
    NSString *nearbyParameters = _nearbySectionView.parameterString;
    
    NSString *fixedNearbyParameters = ([nearbyParameters length]) ? [nearbyParameters stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"&"] : @"";
    NSString *parameters = [favoritesParameters stringByAppendingString:fixedNearbyParameters];
//    NSLog(@"%@",parameters);
#warning there can be duplicates in parameter string
    if ([parameters length]) {
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBMultiPredictionsTask delegate:self];
        [predictionHandler multiPredictionsForStops:parameters];
    }
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error && dictionary) {
        NSArray *predictions = dictionary[@"body"][@"predictions"];
        if (predictions) {
            if (![predictions isKindOfClass:[NSArray class]])
                predictions = [NSArray arrayWithObject:predictions];
            
            NSArray *combined = [_favoritesSectionView.stopsView.subviews arrayByAddingObjectsFromArray:_nearbySectionView.stopsView.subviews];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBStopView class]];
            NSArray *stopViews = [combined filteredArrayUsingPredicate:predicate];
            
            for (NSDictionary *busStop in predictions) {
                NSArray *predictionData = busStop[@"direction"][@"prediction"];
                NSArray *predictions;
                if (predictionData) {
                    if (![predictionData isKindOfClass:[NSArray class]])
                        predictionData = @[predictionData];
                    
                    // Only show the first three predictions
                    predictions = [predictionData subarrayWithRange:NSMakeRange(0, MIN(3, [predictionData count]))];
                }
                
                NSString *predictionsString = [GBStop predictionsStringForPredictions:predictions];
                for (GBStopView *stopView in stopViews) {
                    for (GBStop *stop in stopView.stopGroup.stops) {
                        if ([busStop[@"stopTag"] isEqualToString:stop.tag] && [busStop[@"routeTag"] isEqualToString:stop.route.tag]) {
                            [stopView setPredictions:predictionsString forStop:stop];
                            break;
                        }
                    }
                }
            }
        }
    } else {
        //error handling
    }
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    NSLog(@"http error (%li) %@", (long)code, message);
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    [self updatePredictions];
}

@end
