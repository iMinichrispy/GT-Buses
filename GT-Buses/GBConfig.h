//
//  GBConfig.h
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@class GBRequestConfig;
@interface GBConfig : NSObject

@property (nonatomic, strong) NSString *agency;
@property (nonatomic, strong) GBRequestConfig *requestConfig;
@property (nonatomic, getter=isParty) BOOL party;
@property (nonatomic) BOOL showsArrivalTime;
@property (nonatomic) BOOL showsBusIdentifiers;
@property (nonatomic) BOOL updateAvailable;
@property (nonatomic) BOOL adsVisible;
@property (nonatomic) BOOL canSelectAgency;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) NSInteger buildingsVersion;

+ (GBConfig *)sharedInstance;
- (void)handleConfig:(NSDictionary *)config;

@end
