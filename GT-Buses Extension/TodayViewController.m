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

@import NotificationCenter;

@interface TodayViewController () <NCWidgetProviding, RequestHandlerDelegate>

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSMutableArray *stopViews;
@property (nonatomic, strong) NSString *parameterString;

@end

@implementation TodayViewController

static NSString * const GBMultiPredictionsTask = @"GBMultiPredictionsTask";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
        _parameterString = @"?";
    }
    return self;
}

- (void)updateLayout {
    NSMutableArray *constraints = [NSMutableArray new];
    
    if ([_stops count]) {
        _stopViews = [NSMutableArray new];
        for (NSDictionary *dictionary in _stops) {
            GBStop *stop = [dictionary toStop];
            
            GBStopView *stopView = [[GBStopView alloc] initWithStop:stop];
            [self.view addSubview:stopView];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stopView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(stopView)]];
            [_stopViews addObject:stopView];
            
            if ([_parameterString length] > 1) {
                NSString *parameter = FORMAT(@"&stops=%@%%7C%@", stop.routeTag, stop.tag);
                _parameterString = [_parameterString stringByAppendingString:parameter];
            } else {
                NSString *parameter = FORMAT(@"stops=%@%%7C%@", stop.routeTag, stop.tag);
                _parameterString = [_parameterString stringByAppendingString:parameter];
            }
            
        }
        
        for (int i = 1; i < [_stopViews count]; ++i) {
            [self addSpacingFromTopView:_stopViews[i - 1] toBottomView:_stopViews[i]];
        }
        
        GBStopView *first = [_stopViews firstObject];
        GBStopView *last = [_stopViews lastObject];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
    } else {
        NSLog(@"error");
        _parameterString = nil;
        _stopViews = nil;
        // display error that stops need to be added
    }
    
    [self.view addConstraints:constraints];
    [self updatePredictions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(0, 0);
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBUserDefaultsExtensionSuiteName];
    _stops = [shared objectForKey:@"stops"];
    
    [self updateLayout];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)addSpacingFromTopView:(UIView *)topView toBottomView:(UIView *)bottomView {
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-spacing-[bottomView]" options:0 metrics:@{@"spacing":@4} views:NSDictionaryOfVariableBindings(topView, bottomView)]];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self updatePredictions];
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBUserDefaultsExtensionSuiteName];
    _stops = [shared objectForKey:@"stops"];
    [self updateLayout];
}

#pragma mark - Request Handler

- (void)updatePredictions {
    NSLog(@"update: %@",_parameterString);
    if ([_stops count]) {
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBMultiPredictionsTask delegate:self];
        [predictionHandler multiPredictionsForStops:_parameterString];
    }
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error && dictionary) {
        NSLog(@"%@",dictionary);
        NSArray *predictions = dictionary[@"body"][@"predictions"];
        if (predictions) {
            if (![predictions isKindOfClass:[NSArray class]])
                predictions = [NSArray arrayWithObject:predictions];
            
            NSMutableArray *stopViews = [_stopViews mutableCopy];
            
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
                
                // remove object from what were iterating over and break
                
//                
//                NSString *stopTag = busStop[@"stopTag"];
//                for (int x = 0; x < [busStopAnnotations count]; x++) {
//                    GBBusStopAnnotation *busStopAnnotation = busStopAnnotations[x];
//                    if ([busStopAnnotation.stop.tag isEqualToString:stopTag]) {
//                        if ([predictions count]) {
//                            NSMutableString *subtitle = [NSMutableString stringWithString:@"Next: "];
//                            
//                            NSDictionary *lastPredication = [predictions lastObject];
//                            for (NSDictionary *prediction in predictions) {
//                                [subtitle appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
//                            }
//                            busStopAnnotation.subtitle = subtitle;
//                        }
//                        else busStopAnnotation.subtitle = @"No Predictions";
//                        
//                        // It's okay to remove an element while iterating since we're breaking anyway
//                        // Using a double for loop so this alows us to iterate over fewer elements the next time
//                        [busStopAnnotations removeObject:busStopAnnotation];
//                        break;
//                    }
//                }
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
    NSLog(@"Tap Gesture");
    [self updatePredictions];
}

@end
