//
//  GBStop.h
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@class GBStop;
@interface NSDictionary (GBStop)

- (GBStop *)toStop;
- (GBStop *)xmlToStop;

@end

@class GBRoute, GBDirection;
@interface GBStop : NSObject

@property (nonatomic, strong) GBRoute *route;
@property (nonatomic, strong) GBDirection *direction;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, getter=isFavorite) BOOL favorite;
@property (nonatomic, strong) NSString *predictions;

- (instancetype)initWithRoute:(GBRoute *)route title:(NSString *)title tag:(NSString *)tag;
- (NSDictionary *)toDictionary;
+ (NSString *)predictionsStringForPredictions:(NSArray *)predictions;

@end
