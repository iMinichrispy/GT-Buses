//
//  Colors.h
//  GT-Buses
//
//  Created by Alex Perez on 1/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BLUE_COLOR  [UIColor colorWithRed:(24/255.0) green:(124/255.0) blue:(199/255.0) alpha:1.0]
//#define BLUE_COLOR  [UIColor colorWithRed:(230/255.0) green:(207/255.0) blue:(98/255.0) alpha:1.0]


@interface Colors : NSObject

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

@interface UIImage (Overlay)

- (UIImage *)imageWithColor:(UIColor *)color;

@end

@interface UIColor (DarkerColor)

- (UIColor *)darkerColor:(float)rate;

@end