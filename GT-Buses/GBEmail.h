//
//  GBEmail.h
//  GT-Buses
//
//  Created by Alex Perez on 9/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBEmail : NSObject

@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *recipients;
@property (nonatomic, strong) NSString *body;

+ (GBEmail *)defaultEmail;

@end

@interface GBSupportEmail : GBEmail

@end

@interface GBDebugEmail : GBEmail

@end
