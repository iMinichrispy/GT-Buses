//
//  GBStopView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class GBStop;
@interface GBStopView : UIView

extern float const GBStopViewHeight;

@property (nonatomic, strong) GBStop *stop;
@property (nonatomic, strong) UIImageView *routeImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *predictionsLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;

- (instancetype)initWithStop:(GBStop *)stop;

@end
