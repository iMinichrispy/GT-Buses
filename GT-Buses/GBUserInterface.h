//
//  GBUserInterface.h
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBColors.h"

@interface GBNavigationController : UINavigationController <GBTintColor>

@end

@interface GBLabel : UILabel

@end

@interface GBButton : UIButton <GBTintColor>

@end

@interface GBSegmentedControl : UISegmentedControl

@end
