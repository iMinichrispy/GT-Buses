//
//  GBBorderButton.m
//  GT-Buses
//
//  Created by Alex Perez on 12/24/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBorderButton.h"

#import "GBConstants.h"

@implementation GBBorderButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 5;
        self.titleLabel.font = [UIFont fontWithName:GBFontDefault size:15];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.backgroundColor = (highlighted) ? [UIColor whiteColor] : nil;
}

@end
