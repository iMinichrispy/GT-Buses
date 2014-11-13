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
@property (nonatomic, strong) NSString *parameterString;

@end

@implementation TodayViewController

static NSString * const GBMultiPredictionsTask = @"GBMultiPredictionsTask";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
        _parameterString = @"";
    }
    return self;
}

- (void)updateLayout {
    NSMutableArray *constraints = [NSMutableArray new];
    
    if ([_stops count]) {
        NSMutableArray *stopViews = [NSMutableArray array];
        for (NSDictionary *dictionary in _stops) {
            GBStop *stop = [dictionary toStop];
            
            GBStopView *stopView = [[GBStopView alloc] initWithStop:stop];
            [self.view addSubview:stopView];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stopView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(stopView)]];
            [stopViews addObject:stopView];
            
            NSString *parameter = FORMAT(@"&stops=%@|%@", stop.routeTag, stop.tag);
            _parameterString = [_parameterString stringByAppendingString:parameter];
        }
        
        for (int i = 1; i < [stopViews count]; ++i) {
            [self addSpacingFromTopView:stopViews[i - 1] toBottomView:stopViews[i]];
        }
        
        GBStopView *first = [stopViews firstObject];
        GBStopView *last = [stopViews lastObject];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
    } else {
        _parameterString = nil;
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
    GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithTask:GBMultiPredictionsTask delegate:self];
    [predictionHandler messages];
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error && dictionary) {
        NSLog(@"%@",dictionary);
    } else {
        //error handling
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    
}

@end
