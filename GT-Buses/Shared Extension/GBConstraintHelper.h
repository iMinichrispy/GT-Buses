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

+ (NSArray *)spacingConstraintFromTopView:(UIView *)topView toBottomView:(UIView *)bottomView;
+ (NSArray *)fillConstraint:(UIView *)view horizontal:(BOOL)horizontal;

@end
