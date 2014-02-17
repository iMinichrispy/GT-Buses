//
//  AboutController.m
//  GT-Buses
//
//  Created by Alex Perez on 2/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "AboutController.h"

#define SIDE_WIDTH      150
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AboutController ()

@end

@implementation AboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = BLUE_COLOR;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
        self.navigationController.navigationBar.tintColor = BLUE_COLOR;
    
    self.view.backgroundColor = [BLUE_COLOR darkerColor:0.05];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"%@ (%@)",[infoDict objectForKey:@"CFBundleShortVersionString"],[infoDict objectForKey:@"CFBundleVersion"]];
    
    [self newItemWithTitle:@"Version" value:version atY:36];
    [self newItemWithTitle:@"Developer" value:@"Alex Perez" atY:115];
    [self newItemWithTitle:@"Design" value:@"Felipe Salazar" atY:194];
    
    float offset = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? 0 : -20;
    AvenirButton *supportButton = [[AvenirButton alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-50+offset, SIDE_WIDTH, 40)];
    [supportButton setTitle:@"Support" forState:UIControlStateNormal];
    [supportButton addTarget:self action:@selector(supportEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportButton];
    
    [[UINavigationBar appearance] setTintColor:BLUE_COLOR];
}

- (void)newItemWithTitle:(NSString *)title value:(NSString *)value atY:(float)y {
    float origin = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? 0 : -20;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, origin + y + 25, SIDE_WIDTH, 40)];
    view.backgroundColor = [BLUE_COLOR darkerColor:0.15];
    [self.view addSubview:view];
    
    AvenirLabel *titleLabel = [[AvenirLabel alloc] initWithFrame:CGRectMake(8, origin + y, SIDE_WIDTH, 20) size:14];
    titleLabel.text = title;
    [self.view addSubview:titleLabel];
    
    AvenirLabel *valueLabel = [[AvenirLabel alloc] initWithFrame:CGRectMake(10, origin + y + 35, SIDE_WIDTH, 20) size:16];
    valueLabel.text = value;
    [self.view addSubview:valueLabel];
}

- (void)supportEmail {
    MailComposer *composer = [[MailComposer alloc] initWithDelegate:self];
    [composer showMailPicker];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:@"Your message has failed to send." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
