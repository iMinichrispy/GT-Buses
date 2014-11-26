//
//  GBBus.h
//  GT-Buses
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface GBBus : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) NSInteger heading;

@end
