//
//  GBVibrantLabelView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/13/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSectionHeaderView.h"

#import "GBColors.h"

@implementation GBSectionHeaderView

float const GBSectionHeaderViewHeight = 23.0f;

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.textColor = RGBColor(184, 191, 195);
        [self addSubview:titleLabel];
        
        UIImageView *caretImageView = [[UIImageView alloc] init];
        caretImageView.image = [UIImage imageNamed:@"Caret"];
        caretImageView.contentMode = UIViewContentModeCenter;
        caretImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:caretImageView];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[caretImageView(20)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(caretImageView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel][caretImageView(20)]-7-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, caretImageView)]];
//        [constraints addObject:[NSLayoutConstraint
//                                 constraintWithItem:self
//                                 attribute:NSLayoutAttributeHeight
//                                 relatedBy:NSLayoutRelationEqual
//                                 toItem:nil
//                                 attribute:0
//                                 multiplier:1
//                                 constant:20]];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

@end
