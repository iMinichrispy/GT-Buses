//
//  Colors.m
//  GT-Buses
//
//  Created by Alex Perez on 1/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBColors.h"

#import "GBConstants.h"

//#define YELLOW_COLOR  [UIColor colorWithRed:(230/255.0) green:(207/255.0) blue:(98/255.0) alpha:1.0]

@implementation UIColor (GBColors)

- (UIColor *)darkerColor:(float)rate {
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - rate, 0.0) green:MAX(g - rate, 0.0) blue:MAX(b - rate, 0.0) alpha:a];
    return nil;
}

+ (UIColor *)appTintColor {
    static UIColor *color;
    if (!color) {
#ifdef DEBUG
        color = RGBColor(198, 42, 46);
#else
        color = RGBColor(24, 124, 199);
#endif
    }
    return color;
}

+ (UIColor *)controlTintColor {
    static UIColor *color;
    if (!color) {
        color = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor whiteColor] : [UIColor appTintColor];
    }
    return color;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned int hex;
    [[NSScanner scannerWithString:hexString] scanHexInt:&hex];
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return RGBColor(r, g, b);
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
