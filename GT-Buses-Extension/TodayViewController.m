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
    self.label.text = @"response";
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    if (!error) {
        long long newPredictionUpdate = [[[[dictionary objectForKey:@"body"] objectForKey:@"keyForNextTime"] objectForKey:@"value"] longLongValue];
        if (newPredictionUpdate != lastPredictionUpdate) {
            NSArray *predictions = [[dictionary objectForKey:@"body"] objectForKey:@"predictions"];
            if (predictions) {
                if (![predictions isKindOfClass:[NSArray class]])
                    predictions = [NSArray arrayWithObject:predictions];
                
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@",[BusStopAnnotation class]];
//                NSMutableArray *busStopAnnotations = [[mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                
                NSLog(@"predictions: %@",predictions);
                
                for (NSDictionary *busStop in predictions) {
                    NSArray *predictionData = [[busStop objectForKey:@"direction"] objectForKey:@"prediction"];
                    NSArray *predictions;
                    if (predictionData) {
                        if (![predictionData isKindOfClass:[NSArray class]])
                            predictionData = [NSArray arrayWithObject:predictionData];
                        
                        if ([predictionData count] >= 3)
                            predictions = [predictionData subarrayWithRange:NSMakeRange(0, 3)];
                        else if ([predictionData count] > 0)
                            predictions = [predictionData subarrayWithRange:NSMakeRange(0, [predictionData count])];
                    }
                    
                    self.label.text = [NSString stringWithFormat:@"%@",predictions];
                    /*
                    for (int x = 0; x < [busStopAnnotations count]; x++) {
                        BusStopAnnotation *busStopAnnotation = [busStopAnnotations objectAtIndex:x];
                        if ([busStopAnnotation.stopTag isEqualToString:[busStop objectForKey:@"stopTag"]]) {
                            if (predictions) {
                                NSMutableString *subtitle = [NSMutableString stringWithFormat:@"Next: "];
                                for (int x = 0; x < [predictions count]; x++) {
                                    NSDictionary *prediction = [predictions objectAtIndex:x];
                                    [subtitle appendFormat:(x == [predictions count]-1) ? @"%@" : @"%@, ", [prediction objectForKey:@"minutes"]];
                                }
                                busStopAnnotation.subtitle = ([predictions count] > 0) ? subtitle : @"No Predictions";
                            }
                            else
                                busStopAnnotation.subtitle = @"No Predictions";
                            
                            [busStopAnnotations removeObject:busStopAnnotation];
                            break;
                        }
                    }*/
                }
            }
        }
        lastPredictionUpdate = newPredictionUpdate;
    }
    else
        [self handleError:handler code:4923 message:@"Error Parsing Data"];
    
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
