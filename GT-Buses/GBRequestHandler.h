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
- (void)positionForBus:(NSString *)tag;
- (void)predictionsForBus:(NSString *)tag;

@end
