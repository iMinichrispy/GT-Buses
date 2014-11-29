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

@interface GBDefaultsSwitch : UISwitch

@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSString *key;

@end

@implementation GBDefaultsSwitch

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults key:(NSString *)key {
    self = [super init];
    if (self) {
        _defaults = defaults;
        _key = key;
        
        [self addTarget:self action:@selector(valueDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)valueDidChange:(UISwitch *)sender {
    [_defaults setBool:sender.on forKey:_key];
    [_defaults synchronize];
}

@end


@implementation GBSwitchView

- (instancetype)initWithTitle:(NSString *)title defaults:(NSUserDefaults *)defaults key:(NSString *)key {
    self = [super initWithTitle:title];
    if (self) {
        UISwitch *defaultsSwitch = [[GBDefaultsSwitch alloc] initWithDefaults:defaults key:key];
        defaultsSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setAccessoryView:defaultsSwitch];
        
        [self updateTintColor];
    }
    return self;
}

- (void)updateTintColor {
    ((UISwitch *)self.accessoryView).onTintColor = [UIColor appTintColor];
}

@end
