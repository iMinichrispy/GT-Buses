//
//  GBImage.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

extern float const kRouteImageViewSize;

@class GBStopGroup, GBRoute;
@interface UIImage (GBImage)

+ (UIImage *)arrowImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)circleStopImageWithColor:(UIColor *)color size:(float)size;
+ (UIImage *)circlesWithStopGroup:(GBStopGroup *)stopGroup;
+ (UIImage *)circleRouteImageWithRoute:(GBRoute *)route;

@end
