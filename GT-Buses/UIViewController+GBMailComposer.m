//
//  UIViewController+MailComposer.m
//  GT-Buses
//
//  Created by Alex Perez on 8/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "UIViewController+GBMailComposer.h"

#import "GBConstants.h"
#import "GBEmail.h"

@implementation UIViewController (GBMailComposer)

- (void)showSupportEmailComposer {
    GBEmail *email = [GBSupportEmail defaultEmail];
    [self showEmailComposerWithEmail:email];
}

- (void)showDebugEmailComposer {
    GBEmail *email = [GBDebugEmail defaultEmail];
    [self showEmailComposerWithEmail:email];
}

- (void)showEmailComposerWithEmail:(GBEmail *)email {
#warning test email works
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
        composeController.mailComposeDelegate = self;
        
        [composeController setSubject:email.subject];
        [composeController setToRecipients:[NSArray arrayWithObject:email.recipients]];
        [composeController setMessageBody:email.body isHTML:NO];
        
        composeController.modalPresentationStyle = UIModalPresentationPageSheet;
        
        [self presentViewController:composeController animated:YES completion:^{
            if IS_IPAD [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    } else {
        NSString *emailString = FORMAT(@"mailto:%@?subject=%@&body=%@", email.recipients, email.subject, email.body);
        emailString = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
    }
}

@end
