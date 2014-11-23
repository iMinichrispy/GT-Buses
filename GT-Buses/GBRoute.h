//
//  GBRoute.h
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@class GBRoute;
@interface NSDictionary (Route)

- (GBRoute *)toRoute;
- (GBRoute *)xmlToRoute;

@end

@interface GBRoute : NSObject

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag;
- (NSDictionary *)toDictionary;

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *hexColor;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSArray *directions;
@property (nonatomic) MKMapRect mapRect;

@end
