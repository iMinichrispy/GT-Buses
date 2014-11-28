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

@interface GBSwitch : UISwitch

@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSString *key;

@end

@implementation GBSwitch

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults key:(NSString *)key {
    self = [super init];
    if (self) {
        _defaults = defaults;
        _key = key;
        
        [self addTarget:self action:@selector(valueDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)valueDidChange:(UISwitch *)sender {;
    [_defaults setBool:sender.on forKey:_key];
    [_defaults synchronize];
}

@end


@implementation GBSwitchView

- (instancetype)initWithTitle:(NSString *)title defaults:(NSUserDefaults *)defaults key:(NSString *)key {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
//        self.backgroundColor = [UIColor redColor];
//        self.layer.borderColor = RGBColor(236, 240, 241).CGColor;
//        self.layer.borderWidth = 1.0f;
//        self.layer.cornerRadius = 4;
        
        _label = [[GBLabel alloc] init];
        _label.text = title;
        _label.textColor = RGBColor(224, 224, 224);
        
        _aSwitch = [[GBSwitch alloc] initWithDefaults:defaults key:key];
        _aSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_label];
        [self addSubview:_aSwitch];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_label]-[_aSwitch]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label, _aSwitch)]];
        [constraints addObject:[GBConstraintHelper centerY:_aSwitch withView:self]];
        [constraints addObject:[NSLayoutConstraint
                                constraintWithItem:self
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:0
                                multiplier:1
                                constant:50]];
        [constraints addObject:[NSLayoutConstraint
                                constraintWithItem:self
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:0
                                multiplier:1
                                constant:250]];
        [constraints addObject:[GBConstraintHelper centerY:_label withView:self]];
        [self addConstraints:constraints];
        
        [self updateTintColor];
    }
    return self;
}

- (void)updateTintColor {
    _aSwitch.onTintColor = [UIColor appTintColor];
}

@end
