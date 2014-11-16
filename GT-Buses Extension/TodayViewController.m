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

@import NotificationCenter;
@import CoreLocation;

@interface TodayViewController () <NCWidgetProviding, RequestHandlerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *favoriteStops;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSMutableArray *nearestStops;

@property (nonatomic, strong) NSMutableArray *favoriteStopViews;
@property (nonatomic, strong) NSMutableArray *nearbyStopViews;
@property (nonatomic, strong) NSString *parameterString;

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _showFavorites = YES; // load from nsuserdefaults
        
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
        _favoriteStops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
        _routes = [shared objectForKey:GBSharedDefaultsRoutesKey];
        
        _nearestStops = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateLayout {
    NSMutableArray *constraints = [NSMutableArray new];
    
    if (_showFavorites) {
        if ([_favoriteStops count]) {
            _favoriteStopViews = [NSMutableArray new];
            
            _parameterString = @"?";
            for (NSDictionary *dictionary in _favoriteStops) {
                GBStop *stop = [dictionary toStop];
                // need to remove no favorites added view
                
                GBStopView *stopView = [[GBStopView alloc] initWithStop:stop];
                [_favoritesSectionView.stopsView addSubview:stopView];
                [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:stopView horizontal:YES]];
                [_favoriteStopViews addObject:stopView];
                
                if ([_parameterString length] > 1) {
                    NSString *parameter = FORMAT(@"&stops=%@%%7C%@", stop.routeTag, stop.tag);
                    _parameterString = [_parameterString stringByAppendingString:parameter];
                } else {
                    NSString *parameter = FORMAT(@"stops=%@%%7C%@", stop.routeTag, stop.tag);
                    _parameterString = [_parameterString stringByAppendingString:parameter];
                }
            }
            
            for (int i = 1; i < [_favoriteStopViews count]; ++i) {
                [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromTopView:_favoriteStopViews[i - 1] toBottomView:_favoriteStopViews[i]]];
            }
            
            GBStopView *first = [_favoriteStopViews firstObject];
            GBStopView *last = [_favoriteStopViews lastObject];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
        } else {
            _parameterString = nil;
            _favoriteStopViews = nil;
            
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
            effectView.translatesAutoresizingMaskIntoConstraints = NO;
            
            
            UILabel *label = [[UILabel alloc] init];
            label.text = @"No favorites added.";
            label.textAlignment = NSTextAlignmentCenter;
            label.translatesAutoresizingMaskIntoConstraints = NO;
            [[effectView contentView] addSubview:label];
            
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:label horizontal:NO]];
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:label horizontal:YES]];
            
            [_favoritesSectionView.stopsView addSubview:effectView];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[effectView]-3-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(effectView)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[effectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(effectView)]];
        }
    } else {
        
    }
    
    
    
    [self.view addConstraints:constraints];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    if ([_routes count]) {
        [_nearestStops removeAllObjects];
        for (NSDictionary *routeDic in _routes) {
            NSString *hexColor = routeDic[@"color"];
            for (NSDictionary *stopDic in routeDic[@"stop"]) {
                GBStop *stop = [[GBStop alloc] initWithRoute:nil title:stopDic[@"title"] tag:stopDic[@"tag"]];
                stop.lat = [stopDic[@"lat"] doubleValue];
                stop.lon = [stopDic[@"lon"] doubleValue];
                stop.hexColor = hexColor;
                
                CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:stop.lat longitude:stop.lon];
                CLLocationDistance distance = [location distanceFromLocation:stopLocation]; //meters (double)
                stop.distance = distance;
                
                [_nearestStops insertObject:stop atIndex:[self indexForStop:stop]];
            }
        }
//        [self updateLayout];
        
        if ([_nearestStops count]) {
            NSLog(@"Nearest Stops:");
#warning combine stops with same name
            // each prediction time gets its own color?
            // stop name is alpha
            _nearbyStopViews = [NSMutableArray new];
            NSMutableArray *constraints = [NSMutableArray new];
            for (int x = 0; x < [_nearestStops count] && x < 5; x++) {
                GBStop *stop = _nearestStops[x];
                
                GBStopView *stopView = [[GBStopView alloc] initWithStop:stop];
                [_nearbySectionView.stopsView addSubview:stopView];
                [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:stopView horizontal:YES]];
                [_nearbyStopViews addObject:stopView];
                
//                if ([_parameterString length] > 1) {
//                    NSString *parameter = FORMAT(@"&stops=%@%%7C%@", stop.routeTag, stop.tag);
//                    _parameterString = [_parameterString stringByAppendingString:parameter];
//                } else {
//                    NSString *parameter = FORMAT(@"stops=%@%%7C%@", stop.routeTag, stop.tag);
//                    _parameterString = [_parameterString stringByAppendingString:parameter];
//                }
            }
            
            
            for (int i = 1; i < [_nearbyStopViews count]; ++i) {
                [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromTopView:_nearbyStopViews[i - 1] toBottomView:_nearbyStopViews[i]]];
            }
            
            GBStopView *first = [_nearbyStopViews firstObject];
            GBStopView *last = [_nearbyStopViews lastObject];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
            [NSLayoutConstraint activateConstraints:constraints];
        }
    }
}

- (NSInteger)indexForStop:(GBStop *)stop {
    int index = 0;
    for (GBStop *aStop in _nearestStops) {
        if (aStop.distance > stop.distance) {
            break;
        } else {
            index++;
        }
    }
    return index;
}

- (void)showUserLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        
    }
//    if (![CLLocationManager locationServicesEnabled]){
//              if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
//              if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
//              if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 40.0f; // min meters required for location update
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    _favoritesSectionView = [[GBSectionView alloc] initWithTitle:GBFavoritesHeaderTitle];
    [_favoritesSectionView.headerView addTarget:self action:@selector(toggleFavorites:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_favoritesSectionView];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_favoritesSectionView horizontal:YES]];
    
    _nearbySectionView = [[GBSectionView alloc] initWithTitle:GBNearbyHeaderTitle];
    [_nearbySectionView.headerView addTarget:self action:@selector(toggleNearby:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_nearbySectionView];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_nearbySectionView horizontal:YES]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_favoritesSectionView]-2-[_nearbySectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_favoritesSectionView, _nearbySectionView)]];
    
    [self.view addConstraints:constraints];
    
    [self updateLayout];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resuse" forIndexPath:indexPath];
    
    cell.textLabel.text = @"Cell yo";
    cell.textLabel.textColor = [UIColor blueColor];
    
    return cell;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self updatePredictions];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    _favoriteStops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
    [self updateLayout];
}

#pragma mark - Request Handler

- (void)updatePredictions {
    if ([_favoriteStopViews count] && _parameterString) {
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBMultiPredictionsTask delegate:self];
        [predictionHandler multiPredictionsForStops:_parameterString];
    }
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error && dictionary) {
//        NSLog(@"%@",dictionary);
        NSArray *predictions = dictionary[@"body"][@"predictions"];
        if (predictions) {
            if (![predictions isKindOfClass:[NSArray class]])
                predictions = [NSArray arrayWithObject:predictions];
            
            NSMutableArray *stopViews = [_favoriteStopViews mutableCopy];
            
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
                
                NSString *predictionsLabelText;
                if ([predictions count]) {
                    NSMutableString *predictionsString = [NSMutableString stringWithString:@"Next: "];
                    NSDictionary *lastPredication = [predictions lastObject];
                    for (NSDictionary *prediction in predictions) {
#if DEBUG
                        int totalSeconds = [prediction[@"seconds"] intValue];
                        double minutes = totalSeconds / 60;
                        double seconds = totalSeconds % 60;
                        NSString *time = FORMAT(@"%.f:%02.f", minutes, seconds);
                        [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", time];
#else
                        [predictionsString appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
#endif
                    }
                    predictionsLabelText = predictionsString;
                    //set prediction string
                } else {
                    predictionsLabelText = @"No Predictions";
                    // no predictions
                }
                
                for (int x = 0; x < [stopViews count]; x ++) {
                    GBStopView *stopView = stopViews[x];
                    
                    if ([busStop[@"stopTag"] isEqualToString:stopView.stop.tag]) {
                        stopView.predictionsLabel.text = predictionsLabelText;
                        [stopViews removeObject:stopView];
                        break;
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
