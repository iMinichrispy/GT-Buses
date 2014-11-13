//
//  GBFavoriteButton.h
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

@class GBBusStopAnnotation;
@interface GBFavoriteButton : UIButton

- (instancetype)initWithBusStopAnnotation:(GBBusStopAnnotation *)annotation;

@end
