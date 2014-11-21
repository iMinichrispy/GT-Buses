//
//  GBMapView.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;

#import "GBColors.h"

@class GBMapView, MKMapView;
@protocol GBMapViewDelegate <NSObject>

- (void)handleError:(GBMapView *)mapView code:(NSInteger)code message:(NSString *)message;

@end

#warning TODO: change name
@interface GBMapView : UIView

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) id<GBMapViewDelegate> delegate;

#warning improperly names
- (void)showUserLocation;
- (void)hideUserLocation;

- (void)requestUpdate;

- (void)resetRefreshTimer;
- (void)invalidateRefreshTimer;

- (void)fixRegion;

@end
