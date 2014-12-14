//
//  GBLabelEffectView.m
//  GT-Buses
//
//  Created by Alex Perez on 12/13/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBLabelEffectView.h"

@implementation GBLabelEffectView

- (instancetype)initWithEffect:(UIVisualEffect *)effect {
    self = [super initWithEffect:effect];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (UIAccessibilityIsReduceTransparencyEnabled())
            [self addSubview:_textLabel];
        else
            [[self contentView] addSubview:_textLabel];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

@end
