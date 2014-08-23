//
//  BusRouteControlView.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@interface GBBusRouteControlView : UIView

@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UISegmentedControl *busRouteControl;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
