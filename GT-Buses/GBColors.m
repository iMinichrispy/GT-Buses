//
//  Colors.m
//  GT-Buses
//
//  Created by Alex Perez on 1/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBColors.h"

#import "GBConstants.h"

//#define BLUE_COLOR  [UIColor colorWithRed:(230/255.0) green:(207/255.0) blue:(98/255.0) alpha:1.0]

@implementation UIColor (GBColors)

+ (UIColor *)blueTintColor {
    return RGBColor(24, 124, 199);
}

+ (UIColor *)redTintColor {
    return RGBColor(198, 42, 46);
}

- (UIColor *)darkerColor:(float)rate {
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - rate, 0.0) green:MAX(g - rate, 0.0) blue:MAX(b - rate, 0.0) alpha:a];
    return nil;
}
#warning querying nsuserdefaults current tint color is inefficient
+ (UIColor *)currentTintColor {
    NSInteger colorValue = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsKeyColor];
    UIColor *tintColor = [self appTintColor:colorValue];
    return tintColor;
}

+ (UIColor *)appTintColor:(GBAppTintColor)color {
    switch (color) {
        case GBAppTintColorRed: return [self redTintColor];
        case GBAppTintColorBlue:
        default: return [self blueTintColor];
    }
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned int hex;
    [[NSScanner scannerWithString:hexString] scanHexInt:&hex];
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

@end


@implementation UIImage (Overlay)

- (UIImage *)imageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
