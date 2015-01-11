//
//  GBBusRouteControlView.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRouteControlView.h"

#import "GBUserInterface.h"
#import "GBConstants.h"

@implementation GBRouteControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.alpha = .9;
        
        _busRouteControl = [[GBSegmentedControl alloc] init];
        _busRouteControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        _errorLabel = [[GBLabel alloc] init];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.font = nil;
        _errorLabel.hidden = YES;
        
        _refreshButton = [[UIButton alloc] init];
        _refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage *refreshImage = [UIImage imageNamed:@"Refresh"];
        [_refreshButton setImage:[refreshImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_refreshButton setImage:[refreshImage imageWithColor:[UIColor colorWithWhite:1 alpha:.3]] forState:UIControlStateHighlighted];
        _refreshButton.hidden = YES;
        
        [self updateTintColor];
        
        [self addSubview:_busRouteControl];
        [self addSubview:_activityIndicator];
        [self addSubview:_errorLabel];
        [self addSubview:_refreshButton];
        
        float segmentedControlSidePadding = IS_IPAD ? 15 : 6;
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[_busRouteControl]-padding-|"
                                          options:0
                                          metrics:@{@"padding":@(segmentedControlSidePadding)}
                                          views:NSDictionaryOfVariableBindings(_busRouteControl)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-padding-[_busRouteControl]-padding-|"
                                          options:0
                                          metrics:@{@"padding":@5}
                                          views:NSDictionaryOfVariableBindings(_busRouteControl)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|[_errorLabel]|"
                                          options:0
                                          metrics:nil
                                          views:NSDictionaryOfVariableBindings(_errorLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-padding-[_errorLabel]-padding-|"
                                          options:0
                                          metrics:@{@"padding":@10}
                                          views:NSDictionaryOfVariableBindings(_errorLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|[_refreshButton]|"
                                          options:0
                                          metrics:nil
                                          views:NSDictionaryOfVariableBindings(_refreshButton)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:[_refreshButton]-10-|"
                                          options:0
                                          metrics:nil
                                          views:NSDictionaryOfVariableBindings(_refreshButton)]];
        [constraints addObject:[NSLayoutConstraint
                                constraintWithItem:_activityIndicator
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                toItem:self
                                attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                constant:0.0]];
        [constraints addObject:[NSLayoutConstraint
                                constraintWithItem:_activityIndicator
                                attribute:NSLayoutAttributeCenterY
                                relatedBy:NSLayoutRelationEqual
                                toItem:self
                                attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                constant:0.0]];
        [self addConstraints:constraints];
    }
    return self;
}

- (void)updateTintColor {
    self.backgroundColor = [UIColor appTintColor];
    _busRouteControl.tintColor = [UIColor controlTintColor];
}

@end
