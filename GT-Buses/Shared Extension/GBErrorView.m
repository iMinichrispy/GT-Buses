//
//  GBErrorView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/16/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBErrorView.h"

#import "GBConstraintHelper.h"

@implementation GBErrorView

- (instancetype)initWithEffect:(UIVisualEffect *)effect {
    self = [super initWithEffect:effect];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [[self contentView] addSubview:_label];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_label]-3-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
        [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_label horizontal:YES]];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

@end
