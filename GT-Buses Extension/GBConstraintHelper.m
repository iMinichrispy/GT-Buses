//
//  GBConstraintHelper.m
//  GT-Buses
//
//  Created by Alex Perez on 11/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConstraintHelper.h"

@implementation GBConstraintHelper

+ (NSArray *)spacingConstraintFromTopView:(UIView *)topView toBottomView:(UIView *)bottomView {
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-spacing-[bottomView]" options:0 metrics:@{@"spacing":@4} views:NSDictionaryOfVariableBindings(topView, bottomView)];
}

+ (NSArray *)fillConstraint:(UIView *)view horizontal:(BOOL)horizontal {
    NSString *format = (horizontal) ? @"H:|[view]|" : @"V:|[view]|";
    return [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
}

@end
