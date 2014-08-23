//
//  BusRouteControlView.m
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBusRouteControlView.h"

#import "GBUserInterface.h"
#import "GBConstants.h"
#import "GBColors.h"

@implementation GBBusRouteControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor appTintColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _busRouteControl = [[GBSegmentedControl alloc] init];
        _busRouteControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        _activityIndicator = [[GBActivityIndicatorView alloc] init];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        _errorLabel = [[GBErrorLabel alloc] init];
        _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _errorLabel.hidden = YES;
        
        [self addSubview:_busRouteControl];
        [self addSubview:_activityIndicator];
        [self addSubview:_errorLabel];
        
        float segmentedControlSidePadding = (IS_IPAD) ? 15 : 5;
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|-padding-[_busRouteControl]-padding-|"
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

@end
