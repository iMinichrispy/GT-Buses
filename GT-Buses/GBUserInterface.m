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

@implementation GBUserInterface

+ (CGSize)screenSize {
    // Because on >=iOS 8, [UIScreen bounds] is orientation-dependent
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

+ (float)originY {
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 0 : -20;
}

@end

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
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    }
    return self;
}

@end


@implementation GBButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor appTintColor] darkerColor:0.2];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:GBFontDefault size:16];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    float colorFactor = highlighted ? 0.26f : 0.2f;
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


@implementation GBErrorLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end


@implementation GBSideBarView

- (void)updateTintColor {
    self.backgroundColor = [[UIColor appTintColor] darkerColor:0.15];
}

@end
