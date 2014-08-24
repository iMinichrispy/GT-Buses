//
//  UIViewController+MailComposer.m
//  GT-Buses
//
//  Created by Alex Perez on 8/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "UIViewController+GBMailComposer.h"

#import "GBConstants.h"
#import "GBSupportEmail.h"

@implementation UIViewController (GBMailComposer)

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
#warning isnt lightcontent invalid on ios 6?
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
