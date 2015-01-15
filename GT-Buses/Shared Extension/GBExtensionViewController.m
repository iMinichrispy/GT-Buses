//
//  GBExtensionViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBExtensionViewController.h"

@import NotificationCenter;

#import "GBLabelEffectView.h"
#import "GBSectionHeaderView.h"
#import "GBRequestHandler.h"
#import "XMLReader.h"
#import "GBStopGroup.h"
#import "GBColors.h"
#import "GBRequestConfig.h"
#import "GBAgency.h"

@interface GBExtensionViewController () <NCWidgetProviding, RequestHandlerDelegate>

@end

@implementation GBExtensionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _updating = NO;
        [self updateDefaults];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)loadView {
    self.view = _sectionView;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    defaultMarginInsets.top += 5;
#if APP_STORE_IMAGE
    defaultMarginInsets.bottom = 7;
#endif
    return defaultMarginInsets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateLayout];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatePredictions)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // For handling orientation changes
    [self updateLayout];
}

- (void)updateLayout {
    // To be overriden by subclasses
    // Subclasses should organize and display stops here
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateDefaults];
    // To be overriden by subclasses
}

- (void)updateDefaults {
    NSUserDefaults *shared = [NSUserDefaults sharedDefaults];
    GBConfig *sharedConfig = [GBConfig sharedInstance];
    NSString *agency = [shared objectForKey:GBSharedDefaultsAgencyKey];
    if ([agency length]) {
        sharedConfig.requestConfig = [[GBRequestConfig alloc] initWithAgency:agency];
    }
    sharedConfig.showsArrivalTime = [shared boolForKey:GBSharedDefaultsShowsArrivalTimeKey];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self updatePredictions];
    completionHandler(NCUpdateResultNewData);
}

- (void)displayError:(NSString *)error {
    GBLabelEffectView *errorView = [[GBLabelEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
    errorView.textLabel.text = error;
    errorView.textLabel.numberOfLines = 0;
    errorView.textLabel.textColor = [UIColor grayExtensionTextColor];
    errorView.textLabel.textAlignment = NSTextAlignmentCenter;
    [_sectionView.stopsView addSubview:errorView];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[errorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(errorView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[errorView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(errorView)]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updatePredictions {
#if APP_STORE_IMAGE
    NSArray *stopViews = _sectionView.stopsView.subviews;
    for (GBStopView *stopView in stopViews) {
        if ([stopView isKindOfClass:[GBStopView class]]) {
            for (GBStop *stop in stopView.stopGroup.stops) {
                NSArray *predictions;
                if (![stop.route.tag isEqualToString:@"night"]) {
                    NSInteger first = 1 + arc4random() % 3;
                    NSInteger second = 9 + arc4random() % 6;
                    NSInteger third = 21 + arc4random() % 11;
                    predictions = @[@{@"minutes":@(first)}, @{@"minutes":@(second)}, @{@"minutes":@(third)}];
                }
                
                NSString *predictionsString = [GBStop predictionsStringForPredictions:predictions];
                [stopView setPredictions:predictionsString forStop:stop];
            }
        }
    }
    
#else
    NSString *parameters = _sectionView.parameterString;
    if ([parameters length]  && !_updating) {
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBRequestMultiPredictionsTask delegate:self];
        [predictionHandler multiPredictionsForStops:parameters];
        _updating = YES;
    }
#endif
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    _updating = NO;
    if (!error && dictionary) {
        NSArray *predictions = dictionary[@"body"][@"predictions"];
        if (predictions) {
            if (![predictions isKindOfClass:[NSArray class]])
                predictions = [NSArray arrayWithObject:predictions];
            
            NSArray *stopViews = _sectionView.stopsView.subviews;
            
            for (NSDictionary *busStop in predictions) {
                NSDictionary *direction = busStop[@"direction"];
                // TODO: Handle multiple directions (there can be more than one)
                if ([direction isKindOfClass:[NSArray class]])
                    direction = [((NSArray *)direction) firstObject];
                
                NSArray *predictionData = direction[@"prediction"];
                
                NSArray *predictions;
                if (predictionData) {
                    if (![predictionData isKindOfClass:[NSArray class]])
                        predictionData = @[predictionData];
                    
                    // Only show the first three predictions
                    predictions = [predictionData subarrayWithRange:NSMakeRange(0, MIN(3, [predictionData count]))];
                }
                
                for (GBStopView *stopView in stopViews) {
                    for (GBStop *stop in stopView.stopGroup.stops) {
                        if ([busStop[@"stopTag"] isEqualToString:stop.tag] && [busStop[@"routeTag"] isEqualToString:stop.route.tag]) {
                            NSString *predictionsString = [GBStop predictionsStringForPredictions:predictions];
                            [stopView setPredictions:predictionsString forStop:stop];
                            break;
                        }
                    }
                }
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:GBRequestErrorDomain code:GBRequestParseError userInfo:nil];
        [self handleError:handler error:error];
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    _updating = NO;
    NSString *errorMessage = [GBRequestHandler errorMessageForCode:[error code]];
    NSArray *stopViews = _sectionView.stopsView.subviews;
    for (GBStopView *stopView in stopViews) {
        stopView.predictionsLabel.text = errorMessage;
    }
}

#define MAX_NUM_STOPS 5
#define NC_ELEMENTS_HEIGHT 94.0
#define ESTIMATED_STOPVIEW_HEIGHT 110.0

- (NSInteger)maxNumberStops {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat freeSpace = screenHeight - NC_ELEMENTS_HEIGHT;
    NSInteger numElements = ceil(freeSpace / ESTIMATED_STOPVIEW_HEIGHT);
    return MIN(numElements, MAX_NUM_STOPS);
}

@end
