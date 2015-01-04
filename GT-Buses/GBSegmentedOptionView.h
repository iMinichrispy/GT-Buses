//
//  GBSegmentedOptionView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/28/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

#import "GBOptionView.h"

@interface GBSegmentedOptionView : GBOptionView

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items;

@end
