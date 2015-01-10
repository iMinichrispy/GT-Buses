//
//  GBUserInterface.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBUserInterface.h"

#import "GBColors.h"
#import "GBConstants.h"

@implementation GBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self updateTintColor];
}

- (void)updateTintColor {
    UIColor *color = [UIColor appTintColor];
    if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationBar.barTintColor = color;
    } else {
        self.navigationBar.tintColor = color;
    }
}

@end


@implementation GBLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor]; // Default background color is white on <=iOS6
        self.textColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.font = [UIFont fontWithName:GBFontDefault size:16];
    }
    return self;
}

@end


@implementation GBButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [[UIColor appTintColor] darkerColor:0];
        self.titleLabel.font = [UIFont fontWithName:GBFontDefault size:17];
        self.layer.cornerRadius = 5;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    float colorFactor = highlighted ? 0.05f : 0;
    self.backgroundColor = [[UIColor appTintColor] darkerColor:colorFactor];
}

- (void)updateTintColor {
    [self setHighlighted:NO];
}

@end


@implementation GBSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        self.apportionsSegmentWidthsByContent = NO;
    }
    return self;
}

@end
