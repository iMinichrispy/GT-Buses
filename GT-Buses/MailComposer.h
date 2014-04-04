//
//  MailComposer.h
//  AirGuitar
//
//  Created by Alex Perez on 1/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "Email.h"
#import "Colors.h"

@interface MailComposer : NSObject

@property (nonatomic,strong) id mailDelegate;

- (id)initWithDelegate:(id)delegate;
- (void)showMailPicker;

@end
