//
//  GBAboutViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 11/23/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSettingsViewController.h"

#import "GBConstants.h"
#import "GBUserInterface.h"
#import "GBConstraintHelper.h"
#import "GBUserInterface.h"
#import "GBConfig.h"
#import "GBSwitchView.h"
#import "UIDevice+Hardware.h"
#import "UIViewController+GBMailComposer.h"

@interface GBSettingsViewController () <UIActionSheetDelegate>

@end

@implementation GBSettingsViewController

- (void)loadView {
    UIView *view;
//    if ([[UIDevice currentDevice] supportsVisualEffects]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    } else {
//        view = [[UIView alloc] init];
//        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//    }
    
    self.view = view;
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[[NSLocale currentLocale] objectForKey:NSLocaleMeasurementSystem]);
    NSLog(@"%@",[[NSLocale currentLocale] displayNameForKey:NSLocaleMeasurementSystem value:@"U.S."]);
    
    // Prediction(s) (times): [In 1][At 9:41am]
    // Distances: [mi][km] - based on locale
    // Bus identifiers: on/off
    
    // 24 hr (locale)
    // km/mi (locale)
    // selected routes
    // update available
#warning distance from top and bottom really needs to vary w/ device height
    
    UILabel *settingsLabel = [[GBLabel alloc] init];
    settingsLabel.text = @"Settings";
    settingsLabel.font = [UIFont fontWithName:GBFontDefault size:23];
    [self.view addSubview:settingsLabel];
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    GBSwitchView *arrivalTimeSwitchView = [[GBSwitchView alloc] initWithTitle:@"Shows Arrival Time" defaults:shared key:GBSharedDefaultsShowsArrivalTimeKey];
    arrivalTimeSwitchView.aSwitch.on = [GBConfig sharedInstance].showsArrivalTime;
    [arrivalTimeSwitchView.aSwitch addTarget:self action:@selector(arrivalTimeDidSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:arrivalTimeSwitchView];
    
    GBSwitchView *busIdentifiersSwitchView = [[GBSwitchView alloc] initWithTitle:@"Show Bus Identifiers" defaults:[NSUserDefaults standardUserDefaults] key:GBUserDefaultsShowsBusIdentifiers];
    busIdentifiersSwitchView.aSwitch.on = [GBConfig sharedInstance].showsBusIdentifiers;
    [busIdentifiersSwitchView.aSwitch addTarget:self action:@selector(busIdentifierDidSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:busIdentifiersSwitchView];
    
    
    UIButton *supportButton = [[GBButton alloc] init];
    //    [supportButton setTitle:NSLocalizedString(@"SUPPORT", @"Support button") forState:UIControlStateNormal];
    [supportButton setTitle:@"Feedback" forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(showSupportMailComposer) forControlEvents:UIControlEventTouchUpInside];
    //    [supportButton addTarget:self action:@selector(toggleRoutes:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportButton];
    
    UIButton *reviewAppButton = [[GBButton alloc] init];
    [reviewAppButton setTitle:@"Review App" forState:UIControlStateNormal];
//    [_appReviewButton setTitle:NSLocalizedString(@"REVIEW_APP", @"Review app button") forState:UIControlStateNormal];
    [self.view addSubview:reviewAppButton];
    
    
    UILabel *copyrightLabel = [[UILabel alloc] init];
    copyrightLabel.text = @"Copyright © 2015 by Alex Perez";
    copyrightLabel.font = [UIFont fontWithName:GBFontDefault size:11];
    copyrightLabel.textColor = RGBColor(133, 133, 133);
    copyrightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:copyrightLabel];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[settingsLabel]-15-[arrivalTimeSwitchView]-10-[busIdentifiersSwitchView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(settingsLabel, arrivalTimeSwitchView, busIdentifiersSwitchView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reviewAppButton(50)]-20-[supportButton(50)]-40-[copyrightLabel]-35-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(copyrightLabel, supportButton, reviewAppButton)]];
    [constraints addObject:[GBConstraintHelper centerX:settingsLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:copyrightLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:arrivalTimeSwitchView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:busIdentifiersSwitchView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:supportButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:supportButton width:200]];
    [constraints addObject:[GBConstraintHelper centerX:reviewAppButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:reviewAppButton width:200]];
    [self.view addConstraints:constraints];
    
//    SBNotificationControlColorSettings *colorSettings = [SBNotificationControlColorSettings editButtonSettingsWithGraphicsQuality];
//    
//    SBNotificationVibrantButton *vibrantButton = [[SBNotificationVibrantButton alloc] initWithColorSettings:colorSettings];
//    [vibrantButton setTitle:@"Review App" forState:UIControlStateNormal];
//    vibrantButton.frame = CGRectMake(0, 0, 140, 35);
//    vibrantButton.center = self.view.center;
//    [[vibrancyEffectView contentView] addSubview:vibrantButton];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    [longPress setMinimumPressDuration:2];
    [reviewAppButton addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
}

- (void)updateTintColor:(NSNotification *)notification {
//    [self updateTintColor];
    for (UIView *view in self.view.subviews) {
        if ([view conformsToProtocol:@protocol(GBTintColorDelegate)])
            [((id<GBTintColorDelegate>)view) updateTintColor];
    }
}

- (void)arrivalTimeDidSwitch:(UISwitch *)sender {
    [GBConfig sharedInstance].showsArrivalTime = sender.on;
}

- (void)busIdentifierDidSwitch:(UISwitch *)sender {
    [GBConfig sharedInstance].showsBusIdentifiers = sender.on;
}

#pragma mark - Action Sheet

- (void)changeColor:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SELECT_COLOR", @"Select color prompt") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        NSArray *tintColors = [GBColors availableTintColors];
        for (NSDictionary *color in tintColors) [actionSheet addButtonWithTitle:color[@"name"]];
        
        if (!IS_IPAD) [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"SELECT_COLOR_CANCEL", @"Select color cancel")]];
        
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MESSAGE_FAILED", @"Mail failed alert tile") message:NSLocalizedString(@"MESSAGE_FAILED_TO_SEND", @"Mail failed alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"MESSAGE_DISMISS", @"Mail failed alert dismiss") otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}



- (void)reviewApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/gtbuses"]];
}

@end
