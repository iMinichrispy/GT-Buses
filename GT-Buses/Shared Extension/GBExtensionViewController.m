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
#import "GBErrorView.h"
#import "GBSectionHeaderView.h"
#import "GBRequestHandler.h"
#import "XMLReader.h"
#import "GBStopGroup.h"

@interface GBExtensionViewController () <NCWidgetProviding, RequestHandlerDelegate>

@end

@implementation GBExtensionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _updating = NO;
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
    // To be overriden?
}

- (void)toggleVisible {
    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self updatePredictions];
    completionHandler(NCUpdateResultNewData);
}

- (void)displayError:(NSString *)error {
    GBErrorView *errorView = [[GBErrorView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
    errorView.label.text = error;
    
    [_sectionView.stopsView addSubview:errorView];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:YES]];
    [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:errorView horizontal:NO]];
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
            
        }
    } else {
        //error handling
    }
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    NSLog(@"http error (%li) %@", (long)code, message);
}

- (NSInteger)maxNumberStops {
#warning calculate this better
    return 5;
}

@end
