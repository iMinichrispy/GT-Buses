//
//  GBConstraintHelper.m
//  GT-Buses
//
//  Created by Alex Perez on 11/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConstraintHelper.h"

@implementation GBConstraintHelper

+ (NSArray *)spacingConstraintFromTopView:(UIView *)topView toBottomView:(UIView *)bottomView spacing:(double)spacing {
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-spacing-[bottomView]" options:0 metrics:@{@"spacing":@(spacing)} views:NSDictionaryOfVariableBindings(topView, bottomView)];
}

+ (NSArray *)spacingConstraintFromLeftView:(UIView *)leftView toRightView:(UIView *)rightView spacing:(double)spacing {
    return [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftView]-spacing-[rightView]" options:0 metrics:@{@"spacing":@(spacing)} views:NSDictionaryOfVariableBindings(leftView, rightView)];
}

+ (NSArray *)fillConstraint:(UIView *)view horizontal:(BOOL)horizontal {
    NSString *format = (horizontal) ? @"H:|[view]|" : @"V:|[view]|";
    return [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
}

+ (NSLayoutConstraint *)centerX:(UIView *)view withView:(UIView *)view2 {
    return [self center:NSLayoutAttributeCenterX view:view withView:view2];
}

+ (NSLayoutConstraint *)centerY:(UIView *)view withView:(UIView *)view2 {
    return [self center:NSLayoutAttributeCenterY view:view withView:view2];
}

+ (NSLayoutConstraint *)center:(NSLayoutAttribute)attribute view:(UIView *)view withView:(UIView *)view2 {
   return [NSLayoutConstraint
           constraintWithItem:view
           attribute:attribute
           relatedBy:NSLayoutRelationEqual
           toItem:view2
           attribute:attribute
           multiplier:1
           constant:0];
}

+ (NSLayoutConstraint *)widthConstraint:(UIView *)view width:(double)width {
    return [self constrantForView:view attribute:NSLayoutAttributeWidth constant:width];
}

+ (NSLayoutConstraint *)heightConstraint:(UIView *)view height:(double)height {
    return [self constrantForView:view attribute:NSLayoutAttributeHeight constant:height];
}

+ (NSLayoutConstraint *)constrantForView:(UIView *)view attribute:(NSLayoutAttribute)attribute constant:(double)constant {
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:attribute
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:0
            multiplier:1
            constant:constant];
}

@end
