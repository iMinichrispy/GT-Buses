//
//  GBFavoriteButton.h
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class GBStop;
@interface GBFavoriteButton : UIButton

// TODO: Views should be decoupled from models
@property (nonatomic, strong) GBStop *stop;

@end
