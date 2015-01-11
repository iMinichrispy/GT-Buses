//
//  GBExtensionViewController.h
//  GT-Buses
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

#import "GBSectionView.h"
#import "GBConstants.h"
#import "GBRoute.h"
#import "GBStop.h"
#import "GBStopView.h"
#import "GBConstraintHelper.h"
#import "GBConfig.h"
#import "NSUserDefaults+SharedDefaults.h"

@interface GBExtensionViewController : UIViewController

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) GBSectionView *sectionView;
@property (nonatomic, getter=isUpdating) BOOL updating;

- (void)updateLayout;
- (void)updatePredictions;
- (void)displayError:(NSString *)error;
- (NSInteger)maxNumberStops;
- (void)userDefaultsDidChange:(NSNotification *)notification;

@end
