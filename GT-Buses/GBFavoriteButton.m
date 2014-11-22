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
    NSMutableArray *stops = [[shared objectForKey:GBSharedDefaultsFavoriteStopsKey] mutableCopy];
    if (!stops) {
        stops = [NSMutableArray new];
    }
    
    NSDictionary *dictionary = [_stop toDictionary];
    if (_stop.favorite) {
        [stops addObject:dictionary];
    } else {
        [stops removeObject:dictionary];
    }
    [shared setObject:stops forKey:GBSharedDefaultsFavoriteStopsKey];
    [shared synchronize];
    
    [self setFavorite:_stop.favorite];
}

- (void)setFavorite:(BOOL)favorite {
    [self setTitle:(favorite) ? @"1" : @"0" forState:UIControlStateNormal];
}

@end
