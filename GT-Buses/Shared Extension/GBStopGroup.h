//
//  GBStopGroup.h
//  GT-Buses
//
//  Created by Alex Perez on 11/16/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@class GBStop;
@interface GBStopGroup : NSObject

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSString *key;
@property (nonatomic) double distance;

- (instancetype)initWithStop:(GBStop *)stop;
- (void)addStop:(GBStop *)stop;
- (GBStop *)firstStop;

@end
