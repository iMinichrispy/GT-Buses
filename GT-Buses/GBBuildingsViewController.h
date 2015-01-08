//
//  GBBuildingsViewController.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class GBBuilding;
@protocol GBBuidlingsDelegate <NSObject>

- (void)didSelectBuilding:(GBBuilding *)building;

@end

@interface GBBuildingsViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, weak) id<GBBuidlingsDelegate> delegate;

@end
