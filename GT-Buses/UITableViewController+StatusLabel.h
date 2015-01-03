//
//  UITableViewController+StatusLabel.h
//  GT-Buses
//
//  Created by Alex Perez on 1/1/15.
//  Copyright (c) 2015 Alex Perez. All rights reserved.
//

@import UIKit;

@interface UITableViewController (StatusLabel)

@property (nonatomic, strong) UILabel *statusLabel;

- (void)setStatus:(NSString *)status;

@end
