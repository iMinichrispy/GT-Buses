//
//  GBSectionView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class GBSectionHeaderView, GBStop, GBStopGroup;
@interface GBSectionView : UIView

@property (nonatomic, strong) GBSectionHeaderView *headerView;
@property (nonatomic, strong) UIView *stopsView;
@property (nonatomic, strong) NSString *parameterString;

- (instancetype)initWithTitle:(NSString *)title;
- (void)toggleStops;
- (void)addParameterForStop:(GBStop *)stop;
- (void)addParametersForStopGroup:(GBStopGroup *)stopGroup;
- (void)reset;

@end
