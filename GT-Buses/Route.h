//
//  Route.h
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Colors.h"

@interface Route : NSObject

- (id)initWithTitle:(NSString *)newTitle tag:(NSString *)newTag;

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSArray *paths;
@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, readwrite) MKCoordinateRegion region;

+ (Route *)toRoute:(NSDictionary *)dic;
+ (MKCoordinateRegion)regionForTag:(NSString *)tag latMax:(float)latMax latMin:(float)latMin lonMax:(float)lonMax lonMin:(float)lonMin;

@end
