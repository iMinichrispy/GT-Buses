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
#import "GBSegmentedControlView.h"

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
    
    // 24 hr (locale)
    // km/mi (locale)
    // selected routes
    // update available
#warning distance from top and bottom really needs to vary w/ device height
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    
    
    
    UILabel *settingsLabel = [[GBLabel alloc] init];
    settingsLabel.text = @"Settings";
    settingsLabel.font = [UIFont fontWithName:GBFontDefault size:23];
    [self.view addSubview:settingsLabel];
    
    
    NSInteger seconds = 300;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"h:mm"];
    
    NSString *formattedPrediction = [formatter stringFromDate:date];
    
    NSString *inString = [NSString stringWithFormat:@"In %i", (int) seconds / 60];
    NSString *atString = [NSString stringWithFormat:@"At %@", formattedPrediction];
    
    GBOptionView *arrivalTimeOptionView = [[GBSegmentedControlView alloc] initWithTitle:@"Predictions:" items:@[inString, atString] defaults:shared key:GBSharedDefaultsShowsArrivalTimeKey];
    UISegmentedControl *arrivalTimeSegmentedControl = (UISegmentedControl *)arrivalTimeOptionView.accessoryView;
    arrivalTimeSegmentedControl.selectedSegmentIndex = [GBConfig sharedInstance].showsArrivalTime;
    [arrivalTimeSegmentedControl addTarget:self action:@selector(arrivalTimeValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:arrivalTimeOptionView];
    
    GBOptionView *distancesOptionView = [[GBSegmentedControlView alloc] initWithTitle:@"Distances:" items:@[@"Mi", @"Km"] defaults:nil key:nil];
    [self.view addSubview:distancesOptionView];
    
    GBOptionView *busIdentifiersSwitchView = [[GBSwitchView alloc] initWithTitle:@"Show Bus Identifiers" defaults:[NSUserDefaults standardUserDefaults] key:GBUserDefaultsShowsBusIdentifiers];
    UISwitch *busIdentifiersSwitch = (UISwitch *)busIdentifiersSwitchView.accessoryView;
    busIdentifiersSwitch.on = [GBConfig sharedInstance].showsBusIdentifiers;
    [busIdentifiersSwitch addTarget:self action:@selector(busIdentifierDidSwitch:) forControlEvents:UIControlEventValueChanged];
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
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[settingsLabel]-15-[arrivalTimeOptionView]-10-[distancesOptionView]-10-[busIdentifiersSwitchView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(settingsLabel, arrivalTimeOptionView, busIdentifiersSwitchView, distancesOptionView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reviewAppButton(50)]-20-[supportButton(50)]-40-[copyrightLabel]-35-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(copyrightLabel, supportButton, reviewAppButton)]];
    [constraints addObject:[GBConstraintHelper centerX:settingsLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:copyrightLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:arrivalTimeOptionView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:busIdentifiersSwitchView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:supportButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:supportButton width:200]];
    [constraints addObject:[GBConstraintHelper centerX:reviewAppButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:reviewAppButton width:200]];
    [constraints addObject:[GBConstraintHelper centerX:distancesOptionView withView:self.view]];
    
    [self.view addConstraints:constraints];
    
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

- (void)arrivalTimeValueChanged:(UISegmentedControl *)sender {
    [GBConfig sharedInstance].showsArrivalTime = sender.selectedSegmentIndex;
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
