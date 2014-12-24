//
//  GBExtensionViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBExtensionViewController.h"

@import NotificationCenter;

#import "GBSectionView.h"
#import "GBLabelEffectView.h"
#import "GBSectionHeaderView.h"
#import "GBRequestHandler.h"
#import "XMLReader.h"
#import "GBStopGroup.h"
#import "GBColors.h"
#import "GBRequestConfig.h"

@interface GBExtensionViewController () <NCWidgetProviding, RequestHandlerDelegate>

@end

@implementation GBExtensionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _updating = NO;
        
        GBConfig *sharedConfig = [GBConfig sharedInstance];
        NSUserDefaults *shared = [NSUserDefaults sharedDefaults];
        
        sharedConfig.showsArrivalTime = [shared boolForKey:GBSharedDefaultsShowsArrivalTimeKey];
        NSString *agency = [shared objectForKey:GBSharedDefaultsAgencyKey];
        GBRequestConfig *requestConfig = [[GBRequestConfig alloc] initWithAgency:agency];
        sharedConfig.requestConfig = requestConfig;
#warning need to handle if agency is nil or requestconfig is nil
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)loadView {
    self.view = _sectionView;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    defaultMarginInsets.top +=5;
    return defaultMarginInsets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateLayout];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatePredictions)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)updateLayout {
    // To be overriden by sublasses
    // Subclasses should organize and display stops here
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    NSUserDefaults *shared = [NSUserDefaults sharedDefaults];
    [GBConfig sharedInstance].showsArrivalTime = [shared boolForKey:GBSharedDefaultsShowsArrivalTimeKey];
    // To be overriden by sublasses
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
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:YES]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[errorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(errorView)]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updatePredictions {
    NSString *parameters = _sectionView.parameterString;
    if ([parameters length]) { // && !isUpdating
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBRequestMultiPredictionsTask delegate:self];
        [predictionHandler multiPredictionsForStops:parameters];
        _updating = YES;
    }
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    _updating = NO; // make sure its the predictions task
    if (!error && dictionary) {
        NSArray *predictions = dictionary[@"body"][@"predictions"];
        if (predictions) {
            if (![predictions isKindOfClass:[NSArray class]])
                predictions = [NSArray arrayWithObject:predictions];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", [GBStopView class]];
            NSArray *stopViews = [_sectionView.stopsView.subviews filteredArrayUsingPredicate:predicate];
            
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
        } else {
#warning wifi error handling
        }
    } else {
        //error handling
    }
}

- (void)handleError:(RequestHandler *)handler error:(NSError *)error {
    
}

#define NC_ELEMENTS_HEIGHT 94.0
#define AVG_STOPVIEW_HEIGHT 110.0

- (NSInteger)maxNumberStops {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat freeSpace = screenHeight - NC_ELEMENTS_HEIGHT;
    NSInteger numElements = ceil(freeSpace / AVG_STOPVIEW_HEIGHT);
    return MIN(numElements, 5);
}

@end
