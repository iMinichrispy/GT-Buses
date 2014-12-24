//
//  GBOptionView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/28/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBOptionView.h"

#import "GBUserInterface.h"
#import "GBConstraintHelper.h"

@implementation GBOptionView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _label = [[GBLabel alloc] init];
        _label.text = title;
        _label.textColor = [UIColor colorWithWhite:.95 alpha:1.0];
        
        [self addSubview:_label];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObject:[NSLayoutConstraint
                                constraintWithItem:self
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:0
                                multiplier:1
                                constant:50]];
        [constraints addObject:[NSLayoutConstraint
                                constraintWithItem:self
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:0
                                multiplier:1
                                constant:280]];
        [constraints addObject:[GBConstraintHelper centerY:_label withView:self]];
        [self addConstraints:constraints];
    }
    return self;
}

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView != accessoryView) {
        _accessoryView = accessoryView;
        
        [self addSubview:_accessoryView];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_label]-[_accessoryView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label, _accessoryView)]];
        [constraints addObject:[GBConstraintHelper centerY:_accessoryView withView:self]];
        [self addConstraints:constraints];
    }
}

- (void)updateTintColor {
    // To be overriden by subclasses
}

@end
