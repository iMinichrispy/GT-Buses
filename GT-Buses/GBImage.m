//
//  GBImage.m
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBImage.h"

#import "GBStopGroup.h"

@implementation UIImage (GBImage)

+ (UIImage *)arrowImageWithColor:(UIColor *)color size:(CGSize)size {
    // Saves the arrow image so only one needs to be created per color & size
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


+ (UIImage *)circleImageWithColor:(UIColor *)color size:(float)size {
    // Saves the dot image so only one needs to be created per color & size
    static NSMutableDictionary *circleImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        circleImages = [[NSMutableDictionary alloc] init];
    });
    
    id <NSCopying> key = @([color hash] + size);
    UIImage *image = circleImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextSetLineWidth(ctx, 2.0);
        CGRect rect = CGRectMake(0, 0, size, size);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        circleImages[key] = image;
    }
    
    return image;
}

@end
