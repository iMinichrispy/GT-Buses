//
//  Route.h
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import MapKit;

@class Route;
@interface NSDictionary (Route)

- (Route *)toRoute;

@end

@interface Route : NSObject

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag;

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic) MKCoordinateRegion region;

@end
