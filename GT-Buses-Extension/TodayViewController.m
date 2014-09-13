//
//  TodayViewController.m
//  GT-Buses-Extension
//
//  Created by Alex Perez on 9/8/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "TodayViewController.h"

@import NotificationCenter;

#import "GBRequestHandler.h"
#import "XMLReader.h"

@interface TodayViewController () <NCWidgetProviding, RequestHandlerDelegate> {
    long long lastPredictionUpdate;
}

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
    
    [self checkStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self checkStatus];
}

- (void)checkStatus {
    GBRequestHandler *request = [[GBRequestHandler alloc] initWithTask:@"task" delegate:self];
    [request predictionsForRoute:@"red"];
}

- (void)handleResponse:(RequestHandler *)handler data:(NSData *)data {
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error && dictionary) {
        long long newPredictionUpdate = [dictionary[@"body"][@"keyForNextTime"][@"value"] longLongValue];
        if (newPredictionUpdate != lastPredictionUpdate) {
            NSArray *predictions = dictionary[@"body"][@"predictions"];
            NSLog(@"Predictions response: %i",[predictions count]);
            if (predictions) {
                if (![predictions isKindOfClass:[NSArray class]])
                    predictions = [NSArray arrayWithObject:predictions];
                
                for (NSDictionary *busStop in predictions) {
                    NSArray *predictionData = busStop[@"direction"][@"prediction"];
                    NSArray *predictions;
                    if (predictionData) {
                        // If object is not array, add it to an array (XML workaround)
                        if (![predictionData isKindOfClass:[NSArray class]])
                            predictionData = [NSArray arrayWithObject:predictionData];
                        
                        // Only show the first three predictions
                        predictions = [predictionData subarrayWithRange:NSMakeRange(0, MIN(3, [predictionData count]))];
                    }
                    //for stop in favorite stops
//                    NSString *stopTag = busStop[@"stopTag"];
//                    for (int x = 0; x < [busStopAnnotations count]; x++) {
//                        GBBusStopAnnotation *busStopAnnotation = busStopAnnotations[x];
//                        if ([busStopAnnotation.stopTag isEqualToString:stopTag]) {
//                            if ([predictions count]) {
//                                NSMutableString *subtitle = [NSMutableString stringWithString:@"Next: "];
//                                NSDictionary *lastPredication = [predictions lastObject];
//                                for (NSDictionary *prediction in predictions) {
//                                    [subtitle appendFormat:prediction == lastPredication ? @"%@" : @"%@, ", prediction[@"minutes"]];
//                                }
//                                busStopAnnotation.subtitle = subtitle;
//                            }
//                            else busStopAnnotation.subtitle = @"No Predictions";
//                            
//                            [busStopAnnotations removeObject:busStopAnnotation];
//                            break;
//                        }
//                    }
                }
            }
        }
        lastPredictionUpdate = newPredictionUpdate;
    } else {
#warning some error
    }

}

@end
