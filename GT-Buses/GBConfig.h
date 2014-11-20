//
//  GBConfig.h
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBConfig : NSObject

@property (nonatomic, getter=isParty) BOOL party;
@property (nonatomic) BOOL showBusIdentifiers;
@property (nonatomic, strong) NSString *message;

+ (GBConfig *)sharedInstance;
- (void)handleConfig:(NSDictionary *)config;

@end
