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

#define PREDICTION_EXAMPLE_SECONDS     300

float const kButtonHeight = 50.0f;
float const kButtonWidth = 200.0f;

@interface GBSettingsViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *reviewAppButton;

@end

@implementation GBSettingsViewController

- (void)loadView {
    UIView *view;
    if ([[UIDevice currentDevice] supportsVisualEffects]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    } else {
        view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    }

    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // selected routes
#warning distance from top and bottom really needs to vary w/ device height
    
    UILabel *settingsLabel = [[GBLabel alloc] init];
    settingsLabel.text = NSLocalizedString(@"SETTINGS", @"Settings title");
    settingsLabel.font = [UIFont fontWithName:GBFontDefault size:23];
    [self.view addSubview:settingsLabel];
    
    GBOptionView *arrivalTimeOptionView = [[GBSegmentedControlView alloc] initWithTitle:NSLocalizedString(@"PREDICTIONS_SETTING", @"Predictions setting title") items:[self arrivalTimeItems]];
    UISegmentedControl *arrivalTimeSegmentedControl = (UISegmentedControl *)arrivalTimeOptionView.accessoryView;
    arrivalTimeSegmentedControl.selectedSegmentIndex = [GBConfig sharedInstance].showsArrivalTime;
    [arrivalTimeSegmentedControl addTarget:self action:@selector(arrivalTimeValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:arrivalTimeOptionView];
    
    GBOptionView *busIdentifiersSwitchView = [[GBSwitchView alloc] initWithTitle:NSLocalizedString(@"SHOW_BUS_IDENTIFIERS", @"Toggle for showing bus identifiers")];
    UISwitch *busIdentifiersSwitch = (UISwitch *)busIdentifiersSwitchView.accessoryView;
    busIdentifiersSwitch.on = [GBConfig sharedInstance].showsBusIdentifiers;
    [busIdentifiersSwitch addTarget:self action:@selector(busIdentifierDidSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:busIdentifiersSwitchView];
    
    UIButton *toggleRoutesButton = [[GBBorderButton alloc] init];
    [toggleRoutesButton setTitle:@"Toggle Routes" forState:UIControlStateNormal];
    [self.view addSubview:toggleRoutesButton];
    
    _messageLabel = [[GBLabel alloc] init];
    _messageLabel.font = [UIFont fontWithName:GBFontDefault size:16];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.text = [[GBConfig sharedInstance] message];
    [self.view addSubview:_messageLabel];
    
    UIButton *supportButton = [[GBButton alloc] init];
    [supportButton setTitle:NSLocalizedString(@"SUPPORT", @"Support button") forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(showSupportMailComposer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportButton];
    
    _reviewAppButton = [[GBButton alloc] init];
    [_reviewAppButton setTitle:NSLocalizedString(@"REVIEW_APP", @"Review app button") forState:UIControlStateNormal];
    [_reviewAppButton addTarget:self action:@selector(reviewApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_reviewAppButton];
    
    UILabel *copyrightLabel = [[UILabel alloc] init];
    copyrightLabel.text = NSLocalizedString(@"COPYRIGHT", @"Copyright");
    copyrightLabel.font = [UIFont fontWithName:GBFontDefault size:11];
    copyrightLabel.textColor = RGBColor(133, 133, 133);
    copyrightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:copyrightLabel];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[settingsLabel]-15-[arrivalTimeOptionView]-10-[busIdentifiersSwitchView]-12-[toggleRoutesButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(settingsLabel, arrivalTimeOptionView, busIdentifiersSwitchView, toggleRoutesButton)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_messageLabel]-7-[_reviewAppButton(buttonHeight)]-20-[supportButton(buttonHeight)]-40-[copyrightLabel]-35-|" options:0 metrics:@{@"buttonHeight":@(kButtonHeight)} views:NSDictionaryOfVariableBindings(copyrightLabel, supportButton, _reviewAppButton, _messageLabel)]];
    [constraints addObject:[GBConstraintHelper centerX:settingsLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:copyrightLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:arrivalTimeOptionView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:busIdentifiersSwitchView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:toggleRoutesButton withView:self.view]];
    
    [constraints addObject:[GBConstraintHelper widthConstraint:toggleRoutesButton width:150]];
    [constraints addObject:[GBConstraintHelper heightConstraint:toggleRoutesButton height:40]];
    
    [constraints addObject:[GBConstraintHelper centerX:_messageLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:_messageLabel width:kButtonWidth]];
    [constraints addObject:[GBConstraintHelper centerX:supportButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:supportButton width:kButtonWidth]];
    [constraints addObject:[GBConstraintHelper centerX:_reviewAppButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:_reviewAppButton width:kButtonWidth]];
    [self.view addConstraints:constraints];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    [longPress setMinimumPressDuration:2];
    [_reviewAppButton addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage:) name:GBNotificationMessageDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateiOSVersion:) name:GBNotificationiOSVersionDidChange object:nil];
    
    [self updateMessage:nil];
    [self updateiOSVersion:nil];
}

- (void)updateTintColor:(NSNotification *)notification {
    for (UIView *view in self.view.subviews) {
        if ([view conformsToProtocol:@protocol(GBTintColor)])
            [((id<GBTintColor>)view) updateTintColor];
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

- (NSArray *)arrivalTimeItems {
    NSInteger seconds = PREDICTION_EXAMPLE_SECONDS;
    NSInteger minutes = (int) seconds / 60;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"h:mm"];
    NSString *formattedPrediction = [formatter stringFromDate:date];
    
    NSString *inString = [NSString stringWithFormat:@"%@ %li", NSLocalizedString(@"PREDICTIONS_IN", @"In x, y, ..."), (long) minutes];
    NSString *atString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PREDICTIONS_AT", @"At x, y, ..."), formattedPrediction];
    
    return @[inString, atString];
}

#pragma mark - Config

- (void)updateMessage:(NSNotification *)notification {
    // TODO: Support for localization
    NSString *message = [[GBConfig sharedInstance] message];
    _messageLabel.text = message;
}

- (void)updateiOSVersion:(NSNotification *)notification {
    if ([[GBConfig sharedInstance] updateAvailable]) {
        _messageLabel.text = NSLocalizedString(@"UPDATE_AVAILABLE", @"Update available button");
        [_reviewAppButton setTitle:NSLocalizedString(@"UPDATE_NOW", @"Update now button") forState:UIControlStateNormal];
    } else {
        [_reviewAppButton setTitle:NSLocalizedString(@"REVIEW_APP", @"Review app button") forState:UIControlStateNormal];
        [self updateMessage:nil];
    }
}

@end
