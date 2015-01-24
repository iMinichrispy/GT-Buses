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
#import "GBConfig.h"
#import "GBColors.h"
#import "GBConstants.h"

@implementation UIImage (GBImage)

+ (UIImage *)arrowImageWithColor:(UIColor *)color {
    // Caches the arrow image so only one needs to be created per color & size
    static NSMutableDictionary *arrowImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrowImages = [[NSMutableDictionary alloc] init];
    });
    
    CGSize size = IS_IPAD ? CGSizeMake(24, 32) : CGSizeMake(20, 26);
    CGFloat lineWidth = 4.0;
    if ([[GBConfig sharedInstance] isParty]) {
        size = CGSizeMake(size.width * 4, size.height * 4);
        lineWidth = 10.0;
    }
    
    id <NSCopying> key = @([color hash] / lineWidth);
    UIImage *image = arrowImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        size = CGSizeMake(size.width - lineWidth, size.height - lineWidth);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[color darkerColor:0.4] colorWithAlphaComponent:1].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, lineWidth);
        
        float offset = lineWidth / 2;
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, offset, size.height);                          // Bottom left
        CGPathAddLineToPoint(pathRef, NULL, size.width / 2 + offset, offset);           // Top of arrow
        CGPathAddLineToPoint(pathRef, NULL, size.width + offset, size.height);          // Bottom right
        CGPathAddLineToPoint(pathRef, NULL, size.width / 2 + offset, .8 * size.height); // Center
        CGPathCloseSubpath(pathRef);
        
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        CGPathRelease(pathRef);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        arrowImages[key] = image;
    }
    
    return image;
}


+ (UIImage *)circleStopImageWithColor:(UIColor *)color {
    // Caches the dot image so only one needs to be created per color & size
    static NSMutableDictionary *stopImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stopImages = [[NSMutableDictionary alloc] init];
    });
    
    float size = IS_IPAD ? 17.0f : 10.0f;
    if ([[GBConfig sharedInstance] isParty]) size *= 2;
    
    id <NSCopying> key = @([color hash] / size);
    UIImage *image = stopImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 2.0);
        CGRect rect = CGRectMake(0, 0, size, size);
        CGContextSetFillColorWithColor(context, [color darkerColor:0.3].CGColor);
        CGContextFillEllipseInRect(context, rect);
        
        CGContextRestoreGState(context);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        stopImages[key] = image;
    }
    
    return image;
}

#define STOP_CIRCLE_IMAGE_VIEW_SIZE ((CGSize) {.height = 40.0, .width = 35.0})
float const kStopCircleSize = 25.0f;

+ (UIImage *)circlesWithStopGroup:(GBStopGroup *)stopGroup {
    UIGraphicsBeginImageContextWithOptions(STOP_CIRCLE_IMAGE_VIEW_SIZE, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    // Adding inner shadow aides visibility if there's a route with a white color or when displayed on white background (such as in table view)
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
    static NSMutableDictionary *routeImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeImages = [[NSMutableDictionary alloc] init];
    });
    
    id <NSCopying> key = @([route.color hash]);
    UIImage *image = routeImages[key];
    if (!image) {
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
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        routeImages[key] = image;
    }
    
    return image;
}

@end
