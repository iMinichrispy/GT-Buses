//
//  AvenirUI.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBUserInterface.h"

#import "GBColors.h"
#import "GBConstants.h"

@implementation GBLabel

- (instancetype)initWithFrame:(CGRect)frame size:(float)size {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:GBFontDefault size:size];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

@end


@implementation GBButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor currentTintColor] darkerColor:0.2];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:GBFontDefault size:16];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addTarget:self action:@selector(buttonHighlighted) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchDragOutside];
    }
    return self;
}

- (void)buttonHighlighted {
    self.backgroundColor = [[UIColor currentTintColor] darkerColor:.26];
}

- (void)buttonNormal {
    self.backgroundColor = [[UIColor currentTintColor] darkerColor:0.2];
}

@end


@implementation GBSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        self.apportionsSegmentWidthsByContent = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : [UIColor currentTintColor];
    }
    return self;
}

@end


@implementation GBActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.hidesWhenStopped = YES;
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
        self.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    }
    return self;
}

@end


@implementation GBBusRouteControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.alpha = .9;
    }
    return self;
}

@end
