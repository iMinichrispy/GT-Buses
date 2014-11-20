//
//  GBFavoriteButton.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBFavoriteButton.h"

#import "GBStopAnnotation.h"
#import "GBStop.h"
#import "GBConstants.h"

@interface GBFavoriteButton ()

@property (nonatomic, strong) GBStop *stop;

@end

@implementation GBFavoriteButton

- (instancetype)initWithBusStopAnnotation:(GBStopAnnotation *)annotation {
    self = [super initWithFrame:CGRectMake(0, 0, 30, 30)];
    if (self) {
        _stop = annotation.stop;
        
        [self setFavorite:_stop.isFavorite];
        
        self.backgroundColor = [UIColor redColor];
        [self addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)toggleFavorite:(id)sender {
    _stop.favorite = !_stop.favorite;
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
    NSArray *stops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
    NSMutableSet *stopsSet = [NSMutableSet setWithArray:stops];
    if (!stops) {
        stopsSet = [NSMutableSet new];
    }
    
    NSDictionary *dictionary = [_stop toDictionary];
    if (_stop.favorite) {
        [stopsSet addObject:dictionary];
    } else {
        [stopsSet removeObject:dictionary];
    }
    [shared setObject:stopsSet.allObjects forKey:GBSharedDefaultsFavoriteStopsKey];
    [shared synchronize];
    
    [self setFavorite:_stop.favorite];
}

- (void)setFavorite:(BOOL)favorite {
    [self setTitle:(favorite) ? @"1" : @"0" forState:UIControlStateNormal];
}

@end
