//
//  UIDevice+Hardware.h
//  GT-Buses
//
//  Created by Alex Perez on 11/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface UIDevice (Hardware)

- (BOOL)supportsVisualEffects;
- (NSString *)machineName;

@end
