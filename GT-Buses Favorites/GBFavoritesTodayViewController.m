//
//  TodayViewController.m
//  GT-Buses Favorites
//
//  Created by Alex Perez on 11/21/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBFavoritesTodayViewController.h"

@import NotificationCenter;

@interface GBFavoritesTodayViewController () <NCWidgetProviding>

@end

@implementation GBFavoritesTodayViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sectionView = [[GBSectionView alloc] initWithTitle:NSLocalizedString(@"FAVORITES_SECTION", @"Favorites section title") defaultsKey:@"key"];
        
        NSUserDefaults *shared = [NSUserDefaults sharedDefaults];
        self.stops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
    }
    return self;
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [super userDefaultsDidChange:notification];
    NSUserDefaults *shared = [NSUserDefaults sharedDefaults];
    self.stops = [shared objectForKey:GBSharedDefaultsFavoriteStopsKey];
    [self updateLayout];
}

- (void)updateLayout {
    self.sectionView.parameterString = nil;
    NSMutableArray *constraints = [NSMutableArray new];
    for (UIView *view in self.sectionView.stopsView.subviews) {
        [view removeFromSuperview];
    }
    if ([self.stops count]) {
        NSMutableArray *stopViews = [NSMutableArray new];
        for (NSDictionary *dictionary in self.stops) {
            GBStop *stop = [dictionary toStop];
            
            GBStopView *stopView = [[GBStopView alloc] initWithStop:stop];
            [self.sectionView.stopsView addSubview:stopView];
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:stopView horizontal:YES]];
            [stopViews addObject:stopView];
            
            [self.sectionView addParameterForStop:stop];
        }
        
        for (int i = 1; i < [stopViews count]; i++) {
            [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromTopView:stopViews[i - 1] toBottomView:stopViews[i] spacing:4.0]];
        }
        
        GBStopView *first = [stopViews firstObject];
        GBStopView *last = [stopViews lastObject];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
    } else {
        [self displayError:NSLocalizedString(@"NO_FAVORITES_ADDED", @"No favorites added")];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    [self updatePredictions];
}

@end
