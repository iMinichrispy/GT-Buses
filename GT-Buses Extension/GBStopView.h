//
//  GBStopView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class GBStop, GBStopGroup;
@interface GBStopView : UIView

extern float const GBStopViewHeight;

@property (nonatomic, strong) GBStopGroup *stopGroup;
@property (nonatomic, strong) UIImageView *routeImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *predictionsLabel;
@property (nonatomic, strong) UILabel *directionLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;

- (instancetype)initWithStop:(GBStop *)stop;
- (instancetype)initWithStopGroup:(GBStopGroup *)stopGroup;
- (void)setPredictions:(NSString *)predictions forStop:(GBStop *)stop;

@end
