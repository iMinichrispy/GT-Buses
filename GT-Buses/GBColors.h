//
//  Colors.h
//  GT-Buses
//
//  Created by Alex Perez on 1/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

static inline UIColor *RGBColor(CGFloat red, CGFloat green, CGFloat blue) {
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
}

@interface UIColor (GBColors)

- (UIColor *)darkerColor:(float)rate;
+ (UIColor *)appTintColor;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

@interface UIImage (Overlay)

- (UIImage *)imageWithColor:(UIColor *)color;

@end
