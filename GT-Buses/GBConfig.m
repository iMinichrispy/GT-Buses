//
//  GBConfig.m
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConfig.h"

#import "GBConstants.h"

@interface GBConfig ()

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *routeConfigPath;
@property (nonatomic, strong) NSString *locationsPath;
@property (nonatomic, strong) NSString *predictionsPath;
@property (nonatomic, strong) NSString *messagesPath;

@end

@implementation GBConfig

+ (instancetype)sharedInstance {
    static GBConfig *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseURL = GBConfigBaseURL;
        _routeConfigPath = GBConfigRouteConfigPath;
        _locationsPath = GBConfigLocationsPath;
        _predictionsPath = GBConfigPredictionsPath;
        _messagesPath = GBConfigMessagesPath;
    }
    return self;
}

- (NSString *)routeConfigURL {
    return [_baseURL stringByAppendingString:_routeConfigPath];
}

- (NSString *)locationsBaseURL {
    return [_baseURL stringByAppendingString:_locationsPath];
}

- (NSString *)predictionsBaseURL {
    return [_baseURL stringByAppendingString:_predictionsPath];
}

- (NSString *)messagesURL {
    return [_baseURL stringByAppendingString:_messagesPath];
}

@end
