//
//  GBImage.m
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBImage.h"

#import "GBStop.h"
#import "GBRoute.h"
#import "GBStopGroup.h"
#import "GBRouteCell.h"

@implementation UIImage (GBImage)

+ (UIImage *)arrowImageWithColor:(UIColor *)color size:(CGSize)size {
    // Caches the arrow image so only one needs to be created per color & size
    static NSMutableDictionary *arrowImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrowImages = [[NSMutableDictionary alloc] init];
    });
    
    id <NSCopying> key = @([color hash] + size.width);
    UIImage *image = arrowImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        CGContextSetLineWidth(context, 1.0);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGPathMoveToPoint(pathRef, NULL, 0.0, size.height);                     // Bottom left
        CGPathAddLineToPoint(pathRef, NULL, size.width / 2, 0.0);               // Top of arrow
        CGPathAddLineToPoint(pathRef, NULL, size.width, size.height);           // Bottom right
        CGPathAddLineToPoint(pathRef, NULL, size.width / 2, .71 * size.height); // Center
        CGPathCloseSubpath(pathRef);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        arrowImages[key] = image;
    }
    
    return image;
}


+ (UIImage *)circleStopImageWithColor:(UIColor *)color size:(float)size {
    // Caches the dot image so only one needs to be created per color & size
    static NSMutableDictionary *circleImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        circleImages = [[NSMutableDictionary alloc] init];
    });
    
    id <NSCopying> key = @([color hash] + size);
    UIImage *image = circleImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 2.0);
        CGRect rect = CGRectMake(0, 0, size, size);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, rect);
        
        CGContextRestoreGState(context);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        circleImages[key] = image;
    }
    
    return image;
}

#define STOP_VIEW_IMAGE_VIEW_SIZE ((CGSize) {.height = 40.0, .width = 35.0})
float const kStopCircleSize = 25.0f;

+ (UIImage *)circlesWithStopGroup:(GBStopGroup *)stopGroup {
    UIGraphicsBeginImageContextWithOptions(STOP_VIEW_IMAGE_VIEW_SIZE, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    // Adding inner shadow aides visibility if there's a route with a white color
    CGContextSetShadowWithColor(context, CGSizeZero, 1, [UIColor blackColor].CGColor);
    
    float y = 2;
    for (GBStop *stop in stopGroup.stops) {
        CGRect rect = CGRectMake(3, y, kStopCircleSize - 6, kStopCircleSize - 6);
        
        CGContextSetFillColorWithColor(context, stop.route.color.CGColor);
        
        CGContextFillEllipseInRect(context, rect);
        CGContextStrokeEllipseInRect(context, rect);
        y += 12;
    }
    
    CGContextRestoreGState(context);
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

float const kRouteImageViewSize = 50.0f;
float const kRouteCircleSize = 20.0f;

+ (UIImage *)circleRouteImageWithRoute:(GBRoute *)route {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kRouteImageViewSize, kRouteImageViewSize), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeZero, 1, [UIColor blackColor].CGColor);
    
    CGFloat indent = (kRouteImageViewSize - kRouteCircleSize) / 2;
    CGRect rect = CGRectMake(indent, indent, kRouteCircleSize, kRouteCircleSize);
    
    CGContextSetFillColorWithColor(context, route.color.CGColor);
    
    CGContextFillEllipseInRect(context, rect);
    CGContextStrokeEllipseInRect(context, rect);
    
    CGContextRestoreGState(context);
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

@end
