//
//  AboutController.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "AboutController.h"

#import "GBUserInterface.h"
#import "GBColors.h"
#import "GBConstants.h"
#import "UIViewController+MailComposer.h"

#define SIDE_WIDTH          150
#define SIDE_WIDTH_IPAD     200

@interface AboutController ()

@end

@implementation AboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPAD) {
        self.view.frame = CGRectMake(0, 0, 200, [self frameHeight]);
        [self.view setClipsToBounds:YES];
    }
    
    UIColor *color = [UIColor appTintColor];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = color;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
        self.navigationController.navigationBar.tintColor = color;
    
    self.view.backgroundColor = [color darkerColor:0.05];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"%@ (%@)",[infoDict objectForKey:@"CFBundleShortVersionString"],[infoDict objectForKey:@"CFBundleVersion"]];
    
    [self newItemWithTitle:@"Version" value:version atY:36];
    [self newItemWithTitle:@"Developer" value:@"Alex Perez" atY:115];
    [self newItemWithTitle:@"Design" value:@"Felipe Salazar" atY:194];
    
    float yValue = [self frameHeight] - 50 + [self origin];
    GBButton *supportButton = [[GBButton alloc] initWithFrame:CGRectMake(0, yValue, (IS_IPAD) ? SIDE_WIDTH_IPAD : SIDE_WIDTH, 40)];
    [supportButton setTitle:@"Support" forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(showMailPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportButton];
    
    GBButton *appReviewButton = [[GBButton alloc] initWithFrame:CGRectMake(0, yValue - 50, (IS_IPAD) ? SIDE_WIDTH_IPAD : SIDE_WIDTH, 40)];
    [appReviewButton setTitle:@"Review App" forState:UIControlStateNormal];
    [appReviewButton addTarget:self action:@selector(reviewApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:appReviewButton];
    
    [[UINavigationBar appearance] setTintColor:color];
}

- (void)newItemWithTitle:(NSString *)title value:(NSString *)value atY:(float)y {
    float origin = [self origin];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, origin + y + 25, SIDE_WIDTH_IPAD, 40)];
    view.backgroundColor = [[UIColor appTintColor] darkerColor:0.15];
    [self.view addSubview:view];
    
    GBLabel *titleLabel = [[GBLabel alloc] initWithFrame:CGRectMake(8, origin + y, SIDE_WIDTH, 20) size:14];
    titleLabel.text = title;
    [self.view addSubview:titleLabel];
    
    GBLabel *valueLabel = [[GBLabel alloc] initWithFrame:CGRectMake(10, origin + y + 35, SIDE_WIDTH, 20) size:16];
    valueLabel.text = value;
    [self.view addSubview:valueLabel];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:@"Your message has failed to send." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reviewApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/gtbuses"]];
}

- (float)frameHeight {
    if (IS_IPAD && UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return  [[UIScreen mainScreen] bounds].size.width;
    }
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float)origin {
    return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? 0 : -20;
}

@end
