//
//  GBConfig.h
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBConfig : NSObject

+ (GBConfig *)sharedInstance;
- (NSString *)routeConfigURL;
- (NSString *)locationsBaseURL;
- (NSString *)predictionsBaseURL;
- (NSString *)messagesURL;

@end
