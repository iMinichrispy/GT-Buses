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
#define US_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.8282, -98.5795), MKCoordinateSpanMake(55, 55))

// TODO: Make region specific to each route

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
        
        NSString *agencyTag = [GBConfig sharedInstance].agency.tag;
        
        self.region = ([agencyTag isEqualToString:GBGeorgiaTechAgencyTag]) ? GATECH_REGION : US_REGION;
    }
    return self;
}

@end
