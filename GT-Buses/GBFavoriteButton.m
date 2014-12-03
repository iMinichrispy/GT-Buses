//
//  GBFavoriteButton.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBFavoriteButton.h"

#import "GBStop.h"
#import "GBConstants.h"
#import "GBColors.h"

@implementation GBFavoriteButton

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 26, 25)];
    if (self) {
        [self addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setStop:(GBStop *)stop {
    if (_stop != stop) {
        _stop = stop;
        
        [self setFavorite:_stop.isFavorite];
    }
}

- (void)toggleFavorite:(id)sender {
    _stop.favorite = !_stop.favorite;
    
    NSUserDefaults *shared = [NSUserDefaults sharedDefaults];
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
    UIImage *image = (favorite) ? [UIImage imageNamed:@"Star-Filled"] : [UIImage imageNamed:@"Star"];
    [self setImage:image forState:UIControlStateNormal];
}

@end
