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
#import "GBSwitchOptionView.h"
#import "UIDevice+Hardware.h"
#import "UIViewController+MailComposer.h"
#import "GBSegmentedOptionView.h"
#import "GBToggleRoutesController.h"
#import "GBSettingsButtonsLayout.h"
#import "GBBorderButton.h"
#import "GBSelectAgencyController.h"
#import "GBIAPHelper.h"

#define PREDICTION_EXAMPLE_SECONDS     300

float const kButtonHeight = 50.0f;
float const kButtonWidth = 200.0f;

@interface GBSettingsViewController () <UIActionSheetDelegate, UIAlertViewDelegate> {
    NSArray *_products;
    UILabel *_messageLabel;
    UIButton *_removeAdsButton;
    UIButton *_reviewAppButton;
    UIActivityIndicatorView *_activityIndicator;
}

@end

@implementation GBSettingsViewController

// TODO: Presenting view controllers on detached view controllers is discouraged - warning when presenting view controllers from settings

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
    
    GBOptionView *arrivalTimeOptionView = [[GBSegmentedOptionView alloc] initWithTitle:NSLocalizedString(@"PREDICTIONS_SETTING", @"Predictions setting title") items:[self arrivalTimeItems]];
    UISegmentedControl *arrivalTimeSegmentedControl = (UISegmentedControl *)arrivalTimeOptionView.accessoryView;
    arrivalTimeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    arrivalTimeSegmentedControl.selectedSegmentIndex = [GBConfig sharedInstance].showsArrivalTime;
    [arrivalTimeSegmentedControl addTarget:self action:@selector(arrivalTimeValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:arrivalTimeOptionView];
    
    GBOptionView *busIdentifiersSwitchView = [[GBSwitchOptionView alloc] initWithTitle:NSLocalizedString(@"SHOW_BUS_IDENTIFIERS", @"Toggle for showing bus identifiers")];
    UISwitch *busIdentifiersSwitch = (UISwitch *)busIdentifiersSwitchView.accessoryView;
    busIdentifiersSwitch.on = [GBConfig sharedInstance].showsBusIdentifiers;
    [busIdentifiersSwitch addTarget:self action:@selector(busIdentifierDidSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:busIdentifiersSwitchView];
    
    _messageLabel = [[GBLabel alloc] init];
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
    
    GBSettingsButtonsLayout *buttonLayout = [[GBSettingsButtonsLayout alloc] init];
    [buttonLayout.toggleRoutesButton addTarget:self action:@selector(showToggleRoutes:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLayout.selectAgencyButton addTarget:self action:@selector(showSelectAgency:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLayout.removeAdsButton addTarget:self action:@selector(removeAds:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonLayout];
    _removeAdsButton = buttonLayout.removeAdsButton;
    
    if ([[GBConfig sharedInstance] adsEnabled]) {
        BOOL adsRemoved = [[GBIAPHelper sharedInstance] productPurchased:NBIAPRemoveAdsIdentifier];
        _removeAdsButton.enabled = !adsRemoved;
        if (!adsRemoved) {
            [[GBIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                _products = products;
            }];
        }
    }
    
    if ([buttonLayout.items count] == 3) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:activityIndicator];
        _activityIndicator = activityIndicator;
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_removeAdsButton]-9-[activityIndicator]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_removeAdsButton, activityIndicator)]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_removeAdsButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[busIdentifiersSwitchView]-12-[buttonLayout]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(busIdentifiersSwitchView, buttonLayout)]];
    [constraints addObject:[GBConstraintHelper centerX:buttonLayout withView:self.view]];
    [self.view addConstraints:constraints];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    [longPress setMinimumPressDuration:1];
    [_reviewAppButton addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor:) name:GBNotificationTintColorDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage:) name:GBNotificationMessageDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateiOSVersion:) name:GBNotificationiOSVersionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRemoveAds:) name:GBNotificationAdsVisibleDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFinished:) name:IAPHelperTransactionFinishedNotification object:nil];
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MESSAGE_FAILED", @"Mail failed alert tile") message:NSLocalizedString(@"MESSAGE_FAILED_TO_SEND", @"Mail failed alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"DISMISS", @"Dismiss") otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Config

- (void)updateMessage:(NSNotification *)notification {
    // TODO: Support for localized messages
    NSString *message = [[GBConfig sharedInstance] message];
    _messageLabel.text = message;
    if (![message length] && [[GBConfig sharedInstance] updateAvailable]) {
        [self updateiOSVersion:nil];
    }
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
    if (!IS_IPAD) [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)showSelectAgency:(id)sender {
    GBSelectAgencyController *agencyController = [[GBSelectAgencyController alloc] init];
    GBNavigationController *navController = [[GBNavigationController alloc] initWithRootViewController:agencyController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    if (!IS_IPAD) [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self presentViewController:navController animated:YES completion:NULL];
}

#pragma mark - Remove Ads

- (void)removeAds:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PURCHASE_OR_RESTORE_TITLE", @"Purchase or restore alert title") message:NSLocalizedString(@"PURCHASE_OR_RESTORE_MESSAGE", @"Purchase or restore alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"Cancel") otherButtonTitles:NSLocalizedString(@"PURCHASE", @"Purchase"), NSLocalizedString(@"RESTORE", @"Restore"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([_products count]) {
            SKProduct *product = [_products firstObject];
            [[GBIAPHelper sharedInstance] buyProduct:product];
            [_activityIndicator startAnimating];
        } else {
            [[GBIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                _products = products;
                if (success) {
                    SKProduct *product = (SKProduct *)[products firstObject];
                    [[GBIAPHelper sharedInstance] buyProduct:product];
                    [_activityIndicator startAnimating];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT", @"Alert title") message:NSLocalizedString(@"REQUEST_PRODUCTS_FAIL_MESSAGE", @"Request products alert fail message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
    } else if (buttonIndex == 2) {
        [[GBIAPHelper sharedInstance] restoreCompletedTransactions];
        [_activityIndicator startAnimating];
    }
}

- (void)updateRemoveAds:(NSNotification *)notification {
    BOOL adsRemoved = [[GBIAPHelper sharedInstance] productPurchased:NBIAPRemoveAdsIdentifier];
    _removeAdsButton.enabled = !adsRemoved;
}

- (void)transactionFinished:(NSNotification *)notification {
    [_activityIndicator stopAnimating];
}

@end
