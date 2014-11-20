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

#if DEBUG
- (void)resetBackend;
- (void)updateStops;
- (void)toggleParty;
#endif

+ (NSString *)errorStringForCode:(NSInteger)code;

@end
