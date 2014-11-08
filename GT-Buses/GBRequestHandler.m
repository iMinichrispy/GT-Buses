//
//  GBRequestHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRequestHandler.h"

#import "GBConstants.h"
#import "GBConfig.h"

@implementation GBRequestHandler

- (void)routeConfig {
    [self getRequestWithURL:[[GBConfig sharedInstance] routeConfigURL]];
}

- (void)locationsForRoute:(NSString *)tag {
    NSString *baseURL = [[GBConfig sharedInstance] locationsBaseURL];
    [self getRequestWithURL:FORMAT(@"%@%@", baseURL, tag)];
}

- (void)predictionsForRoute:(NSString *)tag {
    NSString *baseURL = [[GBConfig sharedInstance] predictionsBaseURL];
    [self getRequestWithURL:FORMAT(@"%@%@", baseURL, tag)];
}

- (void)messages {
    [self getRequestWithURL:[[GBConfig sharedInstance] messagesURL]];
}

@end
