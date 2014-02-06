//
//  AboutView.m
//  GT-Buses
//
//  Created by Alex Perez on 2/5/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "AboutView.h"

#define FRAME_WIDTH     250
#define FRAME_HEIGHT    270

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation AboutView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT)];
    if (self) {
        self.alpha = 0;
        self.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        self.backgroundColor = BLUE_COLOR;
    }
    return self;
}

@end
