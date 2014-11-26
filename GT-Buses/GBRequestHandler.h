//
//  GBRequestHandler.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "RequestHandler.h"

@interface GBRequestHandler : RequestHandler

- (void)routeConfig;
- (void)locationsForRoute:(NSString *)tag;
- (void)predictionsForRoute:(NSString *)tag;
- (void)multiPredictionsForStops:(NSString *)parameterList;
- (void)messages;
- (void)buildings;

+ (NSString *)errorStringForCode:(NSInteger)code;
+ (BOOL)isNextBusError:(NSDictionary *)dictionary;

extern NSString * const GBRequestErrorDomain;

enum {
    GBRequestParseError = 2923,
    GBRequestNextbusError = 2943,
};

@end
