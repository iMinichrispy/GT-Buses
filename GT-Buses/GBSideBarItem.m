//
//  GBSideBarItem.m
//  GT-Buses
//
//  Created by Alex Perez on 11/10/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSideBarItem.h"

@implementation GBSideBarItem

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value {
    if (self) {
        _title = title;
        _value = value;
    }
    return self;
}

@end
