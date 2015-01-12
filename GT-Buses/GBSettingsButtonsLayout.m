//
//  GBSettingsButtonsLayout.m
//  GT-Buses
//
//  Created by Alex Perez on 1/11/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

#import "GBSettingsButtonsLayout.h"

#import "GBConfig.h"
#import "GBConstants.h"
#import "GBBorderButton.h"

@implementation GBSettingsButtonsLayout

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSMutableArray *items = [NSMutableArray new];
        
        _toggleRoutesButton = [[GBBorderButton alloc] init];
        [_toggleRoutesButton setTitle:NSLocalizedString(@"TOGGLE_ROUTES", @"Toggle routes button") forState:UIControlStateNormal];
        [items addObject:_toggleRoutesButton];
        
        GBConfig *sharedConfig = [GBConfig sharedInstance];
        if ([sharedConfig canSelectAgency]) {
            _selectAgencyButton = [[GBBorderButton alloc] init];
            [_selectAgencyButton setTitle:NSLocalizedString(@"SELECT_AGENCY", @"Select agency button") forState:UIControlStateNormal];
            [items addObject:_selectAgencyButton];
        }
        
        if ([sharedConfig adsEnabled]) {
            _removeAdsButton = [[GBBorderButton alloc] init];
            [_removeAdsButton setTitle:NSLocalizedString(@"REMOVE_ADS", @"Remove ads button") forState:UIControlStateNormal];
            
            [items addObject:_removeAdsButton];
        }
        
        if ([items count] == 1) {
            _toggleRoutesButton.titleLabel.font = [UIFont fontWithName:GBFontDefault size:16];
        }
        
        self.items = items;
    }
    return self;
}

@end
