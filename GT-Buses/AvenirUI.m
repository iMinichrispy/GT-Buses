//
//  AvenirUI.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "AvenirUI.h"

@implementation AvenirLabel

- (id)initWithFrame:(CGRect)frame size:(float)size {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:@"Avenir-Medium" size:size];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

@end


@implementation AvenirButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [BLUE_COLOR darkerColor:0.2];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addTarget:self action:@selector(buttonHighlighted) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchDragOutside];
    }
    return self;
}

- (void)buttonHighlighted {
    self.backgroundColor = [BLUE_COLOR darkerColor:.26];
}

- (void)buttonNormal {
    self.backgroundColor = [BLUE_COLOR darkerColor:0.2];
}


@end
