//
//  GBFavoriteButton.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBFavoriteButton.h"

#import "GBBusStopAnnotation.h"
#import "GBConstants.h"
#import "GBStop.h"

@interface GBFavoriteButton ()

@property (nonatomic, strong) GBStop *stop;
@property (nonatomic, getter=isFavorite) BOOL favorite;

@end

@implementation GBFavoriteButton

- (instancetype)initWithBusStopAnnotation:(GBBusStopAnnotation *)annotation {
    self = [super initWithFrame:CGRectMake(0, 0, 30, 30)];
    if (self) {
        _favorite = NO;
        _stop = annotation.stop;
        
        self.backgroundColor = [UIColor redColor];
        [self setTitle:@"0" forState:UIControlStateNormal];
        [self addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)toggleFavorite:(id)sender {
    // update image
    // update user defaults
    _favorite = !_favorite;
    
    [self setTitle:(_favorite) ? @"1" : @"0" forState:UIControlStateNormal];
    
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBUserDefaultsExtensionSuiteName];
    NSMutableArray *stops = [[shared objectForKey:@"stops"] mutableCopy];
    if (!stops) {
        stops = [NSMutableArray new];
    }
    
    NSDictionary *dictionary = [_stop toDictionary];
    if (_favorite) {
        [stops addObject:dictionary];
    } else {
        [stops removeObject:dictionary];
    }
    [shared setObject:stops forKey:@"stops"];
    [shared synchronize];
}

@end
