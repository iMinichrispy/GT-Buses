//
//  GBSwitchView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/27/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSwitchView.h"

#import "GBConstraintHelper.h"
#import "GBUserInterface.h"
#import "GBColors.h"


@implementation GBSwitchView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithTitle:title];
    if (self) {
        UISwitch *aSwitch = [[UISwitch alloc] init];
        aSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setAccessoryView:aSwitch];
        
        [self updateTintColor];
    }
    return self;
}

- (void)updateTintColor {
    ((UISwitch *)self.accessoryView).onTintColor = [UIColor appTintColor];
}

@end
