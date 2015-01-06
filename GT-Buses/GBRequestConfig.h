//
//  GBRequestConfig.h
//  GT-Buses
//
//  Created by Alex Perez on 12/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBRequestConfig : NSObject

extern NSString *const GBRequestHerokuBaseURL;

typedef NS_ENUM(NSInteger, GBRequestConfigSource) {
    GBRequestConfigSourceHeroku,
    GBRequestConfigSourceNextbusPublic
};

- (instancetype)initWithAgency:(NSString *)agency;

@property (nonatomic) GBRequestConfigSource source;
@property (nonatomic, strong) NSString *agency;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *routeConfigURL;
@property (nonatomic, strong) NSString *locationsBaseURL;
@property (nonatomic, strong) NSString *predictionsBaseURL;
@property (nonatomic, strong) NSString *multiPredictionsBaseURL;
@property (nonatomic, strong) NSString *scheduleURL;
@property (nonatomic, strong) NSString *messagesURL;

@end
