//
//  GBSupportEmail.h
//  GT-Buses
//
//  Created by Alex Perez on 9/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBSupportEmail : NSObject

+ (NSString *)subject;
+ (NSString *)recipients;
+ (NSString *)body;

@end
