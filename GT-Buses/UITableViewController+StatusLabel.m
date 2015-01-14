//
//  UITableViewController+StatusLabel.m
//  GT-Buses
//
//  Created by Alex Perez on 1/1/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

#import "UITableViewController+StatusLabel.h"

#import <objc/runtime.h>
#import "GBConstants.h"

static char const *const StatusLabelKey = "StatusLabelKey";

double const kMaxLabelWidth = 290.0;

@implementation UITableViewController (StatusLabel)
@dynamic statusLabel;

- (void)setStatus:(NSString *)status {
    BOOL showStatus = [status length];
    if (showStatus && !self.statusLabel) {
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.text = status;
        self.statusLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.font = [UIFont boldSystemFontOfSize:18.0];
        self.statusLabel.numberOfLines = 0;
        self.statusLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.statusLabel];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSMutableArray *constraints = [NSMutableArray new];
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:self.statusLabel
                                    attribute:NSLayoutAttributeCenterX
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                    attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                    constant:0.0]];
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:self.statusLabel
                                    attribute:NSLayoutAttributeTop
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                    constant:55.0]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=padding-[statusLabel(<=maxWidth)]->=padding-|" options:0 metrics:@{@"padding":@15, @"maxWidth":@(kMaxLabelWidth)} views:@{@"statusLabel":self.statusLabel}]];
            [self.view addConstraints:constraints];
        } else {
            // TODO: <iOS 7 doesn't play nice with constraints, and the label still isn't centered properly
            self.statusLabel.frame = CGRectMake(self.view.frame.size.width / 2 - (kMaxLabelWidth / 2), 47, kMaxLabelWidth, 40);
        }
    } else if (showStatus && self.statusLabel) {
        self.statusLabel.text = status;
    } else if (!showStatus) {
        [self.statusLabel removeFromSuperview];
        self.statusLabel = nil;
    }
}

- (UILabel *)statusLabel {
    return objc_getAssociatedObject(self, StatusLabelKey);
}

- (void)setStatusLabel:(UILabel *)statusLabel {
    objc_setAssociatedObject(self, StatusLabelKey, statusLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
