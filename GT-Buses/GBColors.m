//
//  Colors.m
//  GT-Buses
//
//  Created by Alex Perez on 1/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBColors.h"

#import "GBConstants.h"

@interface GBColors ()

@property (nonatomic, strong) UIColor *currentTintColor;

@end

@implementation GBColors

+ (instancetype)sharedInstance {
    static GBColors *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *tintColors = [GBColors tintColors];
        NSInteger colorIndex = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsKeySelectedColor];
        _currentTintColor = tintColors[colorIndex][@"color"];
    }
    return self;
}

+ (void)setAppTintColor:(UIColor *)color {
    [GBColors sharedInstance].currentTintColor = color;
    NSArray *tintColors = [GBColors tintColors];
    for (int x = 0; x < [tintColors count]; x++) {
        NSDictionary *tintColor = tintColors[x];
        if (tintColor[@"color"] == color) {
            [[NSUserDefaults standardUserDefaults] setInteger:x forKey:GBUserDefaultsKeySelectedColor];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationTintColorDidChange object:color];
}

+ (NSArray *)tintColors {
    NSDictionary *blueColor = @{@"name":@"Blue", @"color":[GBColors blueColor]};
    NSDictionary *redColor = @{@"name":@"Red", @"color":[GBColors redColor]};
    NSDictionary *greenColor = @{@"name":@"Green", @"color":[GBColors greenColor]};
    NSDictionary *pinkColor = @{@"name":@"Pink", @"color":[GBColors pinkColor]};
    NSDictionary *yellowColor = @{@"name":@"Yellow", @"color":[GBColors yellowColor]};
    NSDictionary *darkColor = @{@"name":@"Dark", @"color":[GBColors darkColor]};
    
    NSArray *tintColors = @[blueColor, redColor, greenColor, pinkColor, yellowColor, darkColor];
    
    return tintColors;
}

+ (NSArray *)availableTintColors {
    NSArray *tintColors = [GBColors tintColors];
    NSMutableArray *availableColors = [NSMutableArray new];
    
    for (NSDictionary *color in tintColors) {
        if (color[@"color"] != [GBColors sharedInstance].currentTintColor)
            [availableColors addObject:color];
    }
    
    return availableColors;
}

+ (UIColor *)blueColor {
    static UIColor *color;
    if (!color) {
        color = RGBColor(24, 124, 199);
    }
    return color;
}

+ (UIColor *)redColor {
    static UIColor *color;
    if (!color) {
        color = RGBColor(198, 42, 46);
    }
    return color;
}

+ (UIColor *)greenColor {
    static UIColor *color;
    if (!color) {
        color = RGBColor(38, 166, 91);
    }
    return color;
}

+ (UIColor *)pinkColor {
    static UIColor *color;
    if (!color) {
        color = RGBColor(210, 82, 127);
    }
    return color;
}

+ (UIColor *)yellowColor {
    static UIColor *color;
    if (!color) {
        color = RGBColor(230, 207, 98);
    }
    return color;
}

+ (UIColor *)darkColor {
    static UIColor *color;
    if (!color) {
        color = RGBColor(50, 50, 50);
    }
    return color;
}

@end

@implementation UIColor (GBColors)

- (UIColor *)darkerColor:(float)rate {
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - rate, 0.0) green:MAX(g - rate, 0.0) blue:MAX(b - rate, 0.0) alpha:a];
    return nil;
}

+ (UIColor *)appTintColor {
    return [GBColors sharedInstance].currentTintColor;
}

+ (UIColor *)controlTintColor {
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor whiteColor] : [UIColor appTintColor];
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
