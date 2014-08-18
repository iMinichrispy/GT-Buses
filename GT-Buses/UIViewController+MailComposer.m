//
//  UIViewController+MailComposer.m
//  GT-Buses
//
//  Created by Alex Perez on 8/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "UIViewController+MailComposer.h"

#import "GBConstants.h"
#import "GBSupportEmail.h"
#import "GBColors.h"

@implementation UIViewController (MailComposer)

- (void)showMailPicker {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:[GBSupportEmail subject]];
        [picker setToRecipients:[NSArray arrayWithObject:[GBSupportEmail recipients]]];
        [picker setMessageBody:[GBSupportEmail body] isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:^{
            if (IS_IPAD)
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    } else {
        NSString *recipients = [NSString stringWithFormat:@"mailto:%@", [GBSupportEmail recipients]];
        NSString *subject = [NSString stringWithFormat:@"?subject=%@", [GBSupportEmail subject]];
        NSString *body = [NSString stringWithFormat:@"&body=%@", [GBSupportEmail body]];
        NSString *email = [NSString stringWithFormat:@"%@%@%@", recipients, subject, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

@end
