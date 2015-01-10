//
//  GBMapView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBMapView.h"

#import "GBMapHandler.h"
#import "GBConfig.h"
#import "GBAgency.h"

#define GATECH_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775978, -84.399269), MKCoordinateSpanMake(0.025059, 0.023190))

@interface GBMapView ()

@property (nonatomic, strong) GBMapHandler *mapHandler;

@end

@implementation GBMapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        if ([self respondsToSelector:@selector(setRotateEnabled:)])
            self.rotateEnabled = NO;
        
        _mapHandler = [[GBMapHandler alloc] init];
        self.delegate = _mapHandler;
        
        if ([[[GBConfig sharedInstance] agency].tag isEqualToString:GBGeorgiaTechAgencyTag]) {
            self.region = GATECH_REGION;
        }
    }
    return self;
}

@end
