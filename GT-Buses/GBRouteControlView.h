//
//  GBBusRouteControlView.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBColors.h"

@interface GBRouteControlView : UIView <GBTintColor>

@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UISegmentedControl *busRouteControl;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
