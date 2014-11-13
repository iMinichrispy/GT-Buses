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

@end

@class GBRoute;
@interface GBStop : NSObject

@property (nonatomic, strong) GBRoute *route;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic) double lat;
@property (nonatomic) double lon;

// For use with extension, so we don't have to save entire route object to defaults
@property (nonatomic, strong) NSString *routeTag;
@property (nonatomic, strong) NSString *hexColor;

- (instancetype)initWithRoute:(GBRoute *)route title:(NSString *)title tag:(NSString *)tag;
- (NSDictionary *)toDictionary;

@end