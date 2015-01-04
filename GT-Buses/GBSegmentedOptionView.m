//
//  GBSegmentedOptionView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/28/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSegmentedOptionView.h"

#import "GBUserInterface.h"
#import "GBConstraintHelper.h"

@implementation GBSegmentedOptionView

float const kSegmentedControlWidth = 150.0f;

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items {
    self = [super initWithTitle:title];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UISegmentedControl *segmentedControl = [[GBSegmentedControl alloc] initWithItems:items];
        segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        segmentedControl.tintColor = [UIColor controlTintColor];
        
        [self setAccessoryView:segmentedControl];
        
        [self addConstraint:[GBConstraintHelper widthConstraint:segmentedControl width:kSegmentedControlWidth]];
        
        [self updateTintColor];
    }
    return self;
}

- (void)updateTintColor {
    self.accessoryView.tintColor = [UIColor controlTintColor];
}

@end
