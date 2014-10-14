//
//  AboutController.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAboutController.h"

#import "GBUserInterface.h"
#import "GBColors.h"
#import "GBConstants.h"
#import "UIViewController+GBMailComposer.h"

float const kSideBarItemsInitY = 36.0f;
float const kSideBarItemLabelHeight = 20.0f;
float const kSideBarItemViewHeight = 40.0f;
float const kSideBarItemSpacing = kSideBarItemViewHeight + (kSideBarItemLabelHeight * 2) - 1;

float const kButtonHeight = 40.0f;

@interface GBAboutController () <UIActionSheetDelegate, GBTintColorDelegate>

@end

@implementation GBAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTintColor];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"], info[@"CFBundleVersion"]];
    NSArray *sideBaritems = @[@{@"title":@"Version", @"value":version}, @{@"title":@"Developer", @"value":@"Alex Perez"}, @{@"title":@"Design", @"value":@"Felipe Salazar"}];
    [self addSidebarItems:sideBaritems];
    
    float width = IS_IPAD ? kSideWidthiPad : kSideWidth;
    float yValue = [self frameHeight] - 50 + [self origin];
    NSLog(@"yvalue: %f",yValue);
    GBButton *supportButton = [[GBButton alloc] initWithFrame:CGRectMake(0, yValue, width, kButtonHeight)];
    [supportButton setTitle:@"Support" forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(showComposerWithSupportEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportButton];
    
    GBButton *appReviewButton = [[GBButton alloc] initWithFrame:CGRectMake(0, yValue - 50, width, kButtonHeight)];
    [appReviewButton setTitle:@"Review App" forState:UIControlStateNormal];
    [appReviewButton addTarget:self action:@selector(reviewApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:appReviewButton];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    [longPress setMinimumPressDuration:2];
    [appReviewButton addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
}

- (void)addSidebarItems:(NSArray *)sideBaritems {
    float y = [self origin] + kSideBarItemsInitY;
    for (NSDictionary *sideBarItem in sideBaritems) {
        GBSideBarView *view = [[GBSideBarView alloc] initWithFrame:CGRectMake(0, y + 25, kSideWidthiPad, kSideBarItemViewHeight)];
        [view updateTintColor];
        [self.view addSubview:view];
        
        GBLabel *titleLabel = [[GBLabel alloc] init];
        titleLabel.frame = CGRectMake(8, y, kSideWidth, kSideBarItemLabelHeight);
        titleLabel.font = [UIFont fontWithName:GBFontDefault size:14];
        titleLabel.text = sideBarItem[@"title"];
        [self.view addSubview:titleLabel];
        
        GBLabel *valueLabel = [[GBLabel alloc] init];
        valueLabel.frame = CGRectMake(10, y + 35, kSideWidth, kSideBarItemLabelHeight);
        valueLabel.font = [UIFont fontWithName:GBFontDefault size:16];
        valueLabel.text = sideBarItem[@"value"];
        [self.view addSubview:valueLabel];
        
        y += kSideBarItemSpacing;
    }
}

- (float)frameHeight {
#warning this cant be right?
//    if (IS_IPAD && UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
//        NSLog(@"1: %f",[[UIScreen mainScreen] bounds].size.width);
//        return [[UIScreen mainScreen] bounds].size.width;
//    }
//    NSLog(@"2: %f",[[UIScreen mainScreen] bounds].size.height);
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float)origin {
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 0 : -20;
}

- (void)reviewApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/gtbuses"]];
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

- (void)updateTintColor:(NSNotification *)notification {
    [self updateTintColor];
    for (UIView *view in self.view.subviews) {
        if ([view conformsToProtocol:@protocol(GBTintColorDelegate)])
            [((id<GBTintColorDelegate>)view) updateTintColor];
    }
}

#pragma mark - Action Sheet

- (void)changeColor:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Color:" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        NSArray *tintColors = [GBColors availableTintColors];
        for (NSDictionary *color in tintColors) {
            [actionSheet addButtonWithTitle:color[@"name"]];
        }
        
        if (!IS_IPAD) {
            [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
        }
        
        [actionSheet showFromRect:recognizer.view.frame inView:self.view animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSArray *tintColors = [GBColors availableTintColors];
        NSDictionary *selectedColor = tintColors[buttonIndex];
        UIColor *color = selectedColor[@"color"];
        [GBColors setAppTintColor:color];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:@"Your message has failed to send." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
