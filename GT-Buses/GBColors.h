//
//  GBColors.h
//  GT-Buses
//
//  Created by Alex Perez on 1/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;
@import UIKit;

static inline UIColor *RGBColor(CGFloat red, CGFloat green, CGFloat blue) {
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
}

@protocol GBTintColor <NSObject>

@required
- (void)updateTintColor;

@end

@interface GBColors : NSObject

+ (UIColor *)defaultColor;
+ (void)setAppTintColor:(UIColor *)color;
+ (NSArray *)availableTintColors;

@end

@interface UIColor (GBColors)

- (UIColor *)darkerColor:(float)rate;
+ (UIColor *)appTintColor;
+ (UIColor *)controlTintColor;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

@interface UIImage (Overlay)

- (UIImage *)imageWithColor:(UIColor *)color;

@end
