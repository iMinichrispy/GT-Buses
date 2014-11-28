//
//  GBAboutController.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAboutController.h"

#import "GBUserInterface.h"
#import "GBColors.h"
#import "GBConstants.h"
#import "GBConfig.h"
#import "GBSideBarItem.h"
#import "UIViewController+GBMailComposer.h"

float const kButtonHeight = 40.0f;
float const kButtonSpacing = 10.0f;

float const kSideWidth = 150.0f;
float const kSideWidthiPad = 200.0f;

@interface GBAboutController () <UIActionSheetDelegate, GBTintColorDelegate>

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *appReviewButton;

@end

@implementation GBAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTintColor];
    
    UIView *aboutView = [[GBAboutView alloc] init];
    [self.view addSubview:aboutView];
    
    _messageLabel = [[GBLabel alloc] init];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.numberOfLines = 0;
    [aboutView addSubview:_messageLabel];
    
    _appReviewButton = [[GBButton alloc] init];
    [_appReviewButton setTitle:NSLocalizedString(@"REVIEW_APP", @"Review app button") forState:UIControlStateNormal];
    [_appReviewButton addTarget:self action:@selector(reviewApp) forControlEvents:UIControlEventTouchUpInside];
    [aboutView addSubview:_appReviewButton];
    
    UIButton *supportButton = [[GBButton alloc] init];
    [supportButton setTitle:NSLocalizedString(@"SUPPORT", @"Support button") forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(showSupportMailComposer) forControlEvents:UIControlEventTouchUpInside];
    [aboutView addSubview:supportButton];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[aboutView(width)]" options:0 metrics:@{@"width":@([self width])} views:NSDictionaryOfVariableBindings(aboutView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[aboutView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aboutView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_messageLabel]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_messageLabel)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[supportButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(supportButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_appReviewButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_appReviewButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_messageLabel(40)]-5-[_appReviewButton(buttonHeight)]-buttonSpacing-[supportButton(buttonHeight)]-buttonSpacing-|" options:0 metrics:@{@"buttonSpacing":@(kButtonSpacing), @"buttonHeight":@(kButtonHeight)} views:NSDictionaryOfVariableBindings(_messageLabel, _appReviewButton, supportButton)]];
    [self.view addConstraints:constraints];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    [longPress setMinimumPressDuration:2];
    [_appReviewButton addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage:) name:GBNotificationMessageDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateiOSVersion:) name:GBNotificationiOSVersionDidChange object:nil];
}

- (float)width {
    return IS_IPAD ? kSideWidthiPad : kSideWidth;
}

#pragma mark - Tint Color

- (void)updateTintColor {
    UIColor *color = [UIColor appTintColor];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = color;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
        self.navigationController.navigationBar.tintColor = color;
    
    self.view.backgroundColor = [color darkerColor:0.05];
    
    // Sets mail composer navigation bar tint color
    [[UINavigationBar appearance] setTintColor:color];
}


#pragma mark - Message

- (void)updateMessage:(NSNotification *)notification {
    NSString *message = [[GBConfig sharedInstance] message];
    _messageLabel.text = message;
}

- (void)updateiOSVersion:(NSNotification *)notification {
    NSString *iOSVersion = notification.object;
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = info[@"CFBundleShortVersionString"];
    
    if ([iOSVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
        _messageLabel.text = NSLocalizedString(@"UPDATE_AVAILABLE", @"Update available button");
        [_appReviewButton setTitle:NSLocalizedString(@"UPDATE_NOW", @"Update now button") forState:UIControlStateNormal];
    } else {
        [_appReviewButton setTitle:NSLocalizedString(@"REVIEW_APP", @"Review app button") forState:UIControlStateNormal];
        [self updateMessage:nil];
    }
}

@end
