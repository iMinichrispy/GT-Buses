//
//  GBSectionView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSectionView.h"

#import "GBSectionHeaderView.h"
#import "GBConstraintHelper.h"
#import "GBStop.h"
#import "GBRoute.h"
#import "GBStopGroup.h"
#import "GBConfig.h"
#import "GBRequestConfig.h"

@interface GBStopsView : UIView

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation GBStopsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

@end

@interface GBSectionView ()

@property (nonatomic) BOOL stopsVisibile;

@end

@implementation GBSectionView

- (instancetype)initWithTitle:(NSString *)title defaultsKey:(NSString *)defaultsKey {
    self = [super init];
    if (self) {
        _stopsVisibile = YES;
        
        _headerView = [[GBSectionHeaderView alloc] initWithTitle:title];
        [_headerView addTarget:self action:@selector(toggleStops) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_headerView];
        
        _stopsView = [[GBStopsView alloc] init];
        [self addSubview:_stopsView];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_headerView horizontal:YES]];
        [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:_stopsView horizontal:YES]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView]-3-[_stopsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_headerView, _stopsView)]];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

- (void)toggleStops {
    // TODO: Add ability to show/hide stops
}

- (void)addParameterForStop:(GBStop *)stop {
    GBRequestConfig *config = [[GBConfig sharedInstance] requestConfig];
    
    if ([_parameterString length]) {
        NSString *parameter = [NSString stringWithFormat:@"&stops=%@%%7C%@", stop.route.tag, stop.tag];
        _parameterString = [_parameterString stringByAppendingString:parameter];
    } else {
        NSString *string = (config.source == GBRequestConfigSourceHeroku) ? @"?" : @"&";
        
        NSString *parameter = [NSString stringWithFormat:@"%@stops=%@%%7C%@", string, stop.route.tag, stop.tag];
        _parameterString = parameter;
    }
}

- (void)addParametersForStopGroup:(GBStopGroup *)stopGroup {
    for (GBStop *stop in stopGroup.stops) {
        [self addParameterForStop:stop];
    }
}

- (void)reset {
    for (UIView *view in self.stopsView.subviews) {
        [view removeFromSuperview];
    }
}

@end
