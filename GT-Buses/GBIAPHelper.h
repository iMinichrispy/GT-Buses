//
//  GBIAPHelper.h
//  GT-Buses
//
//  Created by Alex Perez on 1/11/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

#import "IAPHelper.h"

extern NSString *const NBIAPRemoveAdsIdentifier;

@interface GBIAPHelper : IAPHelper

+ (GBIAPHelper *)sharedInstance;

@end
