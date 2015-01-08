//
//  GBBuildingsHelper.h
//  GT-Buses
//
//  Created by Alex Perez on 1/7/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBBuildingsHelper : NSObject

+ (NSArray *)savedBuildingsForAgency:(NSString *)agency ignoreExpired:(BOOL)ignoreExpired;
+ (void)setBuildings:(NSArray *)buildings forAgency:(NSString *)agency;

@end
