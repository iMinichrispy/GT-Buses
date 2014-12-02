//
//  GBOptionView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/28/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

#import "GBColors.h"

@interface GBOptionView : UIButton <GBTintColor>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *accessoryView;

- (instancetype)initWithTitle:(NSString *)title;

@end
