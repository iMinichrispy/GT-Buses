//
//  GBSwitchView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/27/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

#import "GBColors.h"

@interface GBSwitchView : UIButton <GBTintColorDelegate>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UISwitch *aSwitch;

- (instancetype)initWithTitle:(NSString *)title defaults:(NSUserDefaults *)defaults key:(NSString *)key;

@end
