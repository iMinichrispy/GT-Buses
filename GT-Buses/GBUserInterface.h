//
//  GBUserInterface.h
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBColors.h"

@interface GBUserInterface : NSObject

+ (CGSize)screenSize;
+ (float)originY;

@end

@interface GBNavigationController : UINavigationController <GBTintColorDelegate>

@end

@interface GBLabel : UILabel

@end

@interface GBButton : UIButton <GBTintColorDelegate>

@end

@interface GBSegmentedControl : UISegmentedControl

@end

@interface GBErrorLabel : UILabel

@end

@interface GBSideBarView : UIView <GBTintColorDelegate>

@end
