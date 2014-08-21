//
//  TodayViewController.m
//  GT-Buses-Extension
//
//  Created by Alex Perez on 6/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "GBRequestHandler.h"
#import "XMLReader.h"

@interface TodayViewController () <NCWidgetProviding, RequestHandlerDelegate> {
    long long lastPredictionUpdate;
}

@end

@implementation TodayViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSExtensionContext
//    NSItemProvider
    
    GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"vehiclePredictions"];
    [predictionHandler predictionsForBus:0];
    self.label.text = @"Request";
    
#warning should be saved stop

    
}

- (void)handleResponse:(RequestHandler *)handler data:(id)data {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"vehiclePredictions"];
    [predictionHandler predictionsForBus:0];
    self.label.text = @"Request";
    
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
