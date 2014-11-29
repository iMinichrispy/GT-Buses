//
//  GBSegmentedControlView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/28/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSegmentedControlView.h"

#import "GBUserInterface.h"
#import "GBConstraintHelper.h"

@interface GBDefaultsSegmentedControl : GBSegmentedControl

@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSString *key;

@end

@implementation GBDefaultsSegmentedControl

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults key:(NSString *)key items:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        _defaults = defaults;
        _key = key;
        
        [self addTarget:self action:@selector(valueDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)valueDidChange:(UISegmentedControl *)sender {
    [_defaults setInteger:sender.selectedSegmentIndex forKey:_key];
    [_defaults synchronize];
}

@end

@implementation GBSegmentedControlView

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items defaults:(NSUserDefaults *)defaults key:(NSString *)key {
    self = [super initWithTitle:title];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UISegmentedControl *segmentedControl = [[GBDefaultsSegmentedControl alloc] initWithDefaults:defaults key:key items:items];
        segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        segmentedControl.tintColor = [UIColor controlTintColor];
        
        [self setAccessoryView:segmentedControl];
        
        [self addConstraint:[GBConstraintHelper widthConstraint:segmentedControl width:140]];
        
        [self updateTintColor];
    }
    return self;
}

- (void)updateTintColor {
//    _segmentedControl.onTintColor = [UIColor appTintColor];
}

@end
