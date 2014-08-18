//
//  BusRouteControlView.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "BusRouteControlView.h"

#import "GBUserInterface.h"
#import "GBConstants.h"
#import "GBColors.h"

@implementation BusRouteControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.busRouteControl = [[GBSegmentedControl alloc] initWithFrame:CGRectMake((IS_IPAD) ? 15 : 5, 5, SCREEN_WIDTH - ((IS_IPAD) ? 30 : 10), 30)];
        self.activityIndicator = [[GBActivityIndicatorView alloc] initWithFrame:CGRectMake(self.center.x - 10, 12, 20, 20)];
        self.errorLabel = [[GBErrorLabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 20)];
        self.errorLabel.hidden = YES;
        
        self.backgroundColor = [UIColor currentTintColor];
        
        [self addSubview:self.busRouteControl];
        [self addSubview:self.activityIndicator];
        [self addSubview:self.errorLabel];
    }
    return self;
}

@end
