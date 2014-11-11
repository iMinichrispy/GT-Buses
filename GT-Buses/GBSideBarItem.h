//
//  GBSideBarItem.h
//  GT-Buses
//
//  Created by Alex Perez on 11/10/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBSideBarItem : NSObject

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *value;

@end
