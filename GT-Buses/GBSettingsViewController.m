//
//  GBSettingsViewController.m
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
#import "UIViewController+MailComposer.h"
#import "GBSegmentedControlView.h"
#import "GBToggleRoutesController.h"
#import "GBHorizontalLayout.h"
#import "GBBorderButton.h"
#import "GBSelectAgencyController.h"

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
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.85];
    }

    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *settingsLabel = [[GBLabel alloc] init];
    settingsLabel.text = NSLocalizedString(@"SETTINGS", @"Settings title");
    settingsLabel.font = [UIFont fontWithName:GBFontDefault size:23];
    [self.view addSubview:settingsLabel];
    
    GBOptionView *arrivalTimeOptionView = [[GBSegmentedControlView alloc] initWithTitle:NSLocalizedString(@"PREDICTIONS_SETTING", @"Predictions setting title") items:[self arrivalTimeItems]];
    UISegmentedControl *arrivalTimeSegmentedControl = (UISegmentedControl *)arrivalTimeOptionView.accessoryView;
    arrivalTimeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    arrivalTimeSegmentedControl.selectedSegmentIndex = [GBConfig sharedInstance].showsArrivalTime;
    [arrivalTimeSegmentedControl addTarget:self action:@selector(arrivalTimeValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:arrivalTimeOptionView];
    
    GBOptionView *busIdentifiersSwitchView = [[GBSwitchView alloc] initWithTitle:NSLocalizedString(@"SHOW_BUS_IDENTIFIERS", @"Toggle for showing bus identifiers")];
    UISwitch *busIdentifiersSwitch = (UISwitch *)busIdentifiersSwitchView.accessoryView;
    busIdentifiersSwitch.on = [GBConfig sharedInstance].showsBusIdentifiers;
    busIdentifiersSwitch.enabled = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"));
    [busIdentifiersSwitch addTarget:self action:@selector(busIdentifierDidSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:busIdentifiersSwitchView];
    
    _messageLabel = [[GBLabel alloc] init];
    _messageLabel.font = [UIFont fontWithName:GBFontDefault size:16];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.text = [[GBConfig sharedInstance] message];
    [self.view addSubview:_messageLabel];
    
    UIButton *supportButton = [[GBButton alloc] init];
    [supportButton setTitle:NSLocalizedString(@"SUPPORT", @"Support button") forState:UIControlStateNormal];
    // TODO: Presenting view controllers on detached view controllers is discouraged
    [supportButton addTarget:self action:@selector(showSupportMailComposer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportButton];
    
    _reviewAppButton = [[GBButton alloc] init];
    [_reviewAppButton setTitle:NSLocalizedString(@"REVIEW_APP", @"Review app button") forState:UIControlStateNormal];
    [_reviewAppButton addTarget:self action:@selector(reviewApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_reviewAppButton];
    
    UILabel *copyrightLabel = [[GBLabel alloc] init];
    copyrightLabel.text = NSLocalizedString(@"COPYRIGHT", @"Copyright");
    copyrightLabel.font = [UIFont fontWithName:GBFontDefault size:11];
    copyrightLabel.textColor = RGBColor(133, 133, 133);
    [self.view addSubview:copyrightLabel];
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[settingsLabel]-15-[arrivalTimeOptionView]-10-[busIdentifiersSwitchView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(settingsLabel, arrivalTimeOptionView, busIdentifiersSwitchView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_messageLabel]-7-[_reviewAppButton(buttonHeight)]-20-[supportButton(buttonHeight)]-20-[copyrightLabel]-35-|" options:0 metrics:@{@"buttonHeight":@(kButtonHeight)} views:NSDictionaryOfVariableBindings(copyrightLabel, supportButton, _reviewAppButton, _messageLabel)]];
    [constraints addObject:[GBConstraintHelper centerX:settingsLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:copyrightLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:arrivalTimeOptionView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:busIdentifiersSwitchView withView:self.view]];
    [constraints addObject:[GBConstraintHelper centerX:_messageLabel withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:_messageLabel width:kButtonWidth]];
    [constraints addObject:[GBConstraintHelper centerX:supportButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:supportButton width:kButtonWidth]];
    [constraints addObject:[GBConstraintHelper centerX:_reviewAppButton withView:self.view]];
    [constraints addObject:[GBConstraintHelper widthConstraint:_reviewAppButton width:kButtonWidth]];
    
    NSMutableArray *items = [NSMutableArray new];
    
    // Only add the toggle routes button if the routes have been retrieved
    NSArray *routes = [[NSUserDefaults sharedDefaults] objectForKey:GBSharedDefaultsRoutesKey];
    if ([routes count]) {
        UIButton *toggleRoutesButton = [[GBBorderButton alloc] init];
        [toggleRoutesButton setTitle:NSLocalizedString(@"TOGGLE_ROUTES", @"Toggle routes") forState:UIControlStateNormal];
        [toggleRoutesButton addTarget:self action:@selector(showToggleRoutes:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:toggleRoutesButton];
    }
    
    GBConfig *sharedConfig = [GBConfig sharedInstance];
    if ([sharedConfig canSelectAgency]) {
        UIButton *selectAgencyButton = [[GBBorderButton alloc] init];
        [selectAgencyButton setTitle:NSLocalizedString(@"SELECT_AGENCY", @"Select agency") forState:UIControlStateNormal];
        [selectAgencyButton addTarget:self action:@selector(showSelectAgency:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:selectAgencyButton];
    }
    
    if ([sharedConfig adsVisible]) {
        UIButton *disableAdsButton = [[GBBorderButton alloc] init];
        [disableAdsButton setTitle:NSLocalizedString(@"DISABLE_ADS", @"Disable ads") forState:UIControlStateNormal];
        [disableAdsButton addTarget:self action:@selector(showToggleRoutes:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:disableAdsButton];
    }
    
    GBHorizontalLayout *horizontalLayout = [[GBHorizontalLayout alloc] init];
    horizontalLayout.translatesAutoresizingMaskIntoConstraints = NO;
    [horizontalLayout addItems:items];
    [self.view addSubview:horizontalLayout];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[busIdentifiersSwitchView]-12-[horizontalLayout]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(busIdentifiersSwitchView, horizontalLayout)]];
    [constraints addObject:[GBConstraintHelper centerX:horizontalLayout withView:self.view]];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Action Sheet

- (void)changeColor:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SELECT_COLOR", @"Select color prompt") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        NSArray *tintColors = [GBColors availableTintColors];
        for (NSDictionary *color in tintColors) [actionSheet addButtonWithTitle:color[@"name"]];
        
        if (!IS_IPAD) [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"Cancel")]];
        
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

- (void)showToggleRoutes:(id)sender {
    GBToggleRoutesController *routesController = [[GBToggleRoutesController alloc] init];
    GBNavigationController *navController = [[GBNavigationController alloc] initWithRootViewController:routesController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)showSelectAgency:(id)sender {
    GBSelectAgencyController *agencyController = [[GBSelectAgencyController alloc] init];
    GBNavigationController *navController = [[GBNavigationController alloc] initWithRootViewController:agencyController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self presentViewController:navController animated:YES completion:NULL];
}

@end
