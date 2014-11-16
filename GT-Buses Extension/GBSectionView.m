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

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _stopsVisibile = YES; // nsuserdefaults
        
        _headerView = [[GBSectionHeaderView alloc] initWithTitle:title];
        [self addSubview:_headerView];
        
        _stopsView = [[GBStopsView alloc] init];
//        _stopsView.translatesAutoresizingMaskIntoConstraints = NO;
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
    if (_stopsVisibile) {
        // hide stops
//        for (UIView *view in _stopsView.subviews) {
//            [view removeFromSuperview];
//        }
//        [_stopsView setNeedsUpdateConstraints];
////        [_stopsView setNeedsLayout];
//        [UIView animateWithDuration:5 animations:^{
//            [_stopsView addConstraint:[NSLayoutConstraint
//                                       constraintWithItem:_stopsView
//                                       attribute:NSLayoutAttributeHeight
//                                       relatedBy:NSLayoutRelationEqual
//                                       toItem:nil
//                                       attribute:0
//                                       multiplier:1
//                                       constant:0]];
//            [_stopsView layoutIfNeeded];
//        }];
        
    } else {
        //show stops
    }
    _stopsVisibile = !_stopsVisibile;
}

- (void)addParameterForStop:(GBStop *)stop {
    if ([_parameterString length]) {
        NSString *parameter = [NSString stringWithFormat:@"&stops=%@%%7C%@", stop.routeTag, stop.tag];
        _parameterString = [_parameterString stringByAppendingString:parameter];
    } else {
        NSString *parameter = [NSString stringWithFormat:@"?stops=%@%%7C%@", stop.routeTag, stop.tag];
        _parameterString = parameter;
    }
}

@end
