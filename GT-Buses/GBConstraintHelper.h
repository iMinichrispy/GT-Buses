//
//  GBConstraintHelper.h
//  GT-Buses
//
//  Created by Alex Perez on 11/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface GBConstraintHelper : NSObject

+ (NSArray *)spacingConstraintFromTopView:(UIView *)topView toBottomView:(UIView *)bottomView spacing:(double)spacing;
+ (NSArray *)spacingConstraintFromLeftView:(UIView *)leftView toRightView:(UIView *)rightView spacing:(double)spacing;
+ (NSArray *)fillConstraint:(UIView *)view horizontal:(BOOL)horizontal;
+ (NSLayoutConstraint *)centerX:(UIView *)view withView:(UIView *)view2;
+ (NSLayoutConstraint *)centerY:(UIView *)view withView:(UIView *)view2;
+ (NSLayoutConstraint *)widthConstraint:(UIView *)view width:(double)width;
+ (NSLayoutConstraint *)heightConstraint:(UIView *)view height:(double)height;

@end
