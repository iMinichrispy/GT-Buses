//
//  GBStopView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStopView.h"

#import "GBStop.h"
#import "GBColors.h"
#import "GBDirection.h"

@import NotificationCenter;

@implementation GBStopView

float const GBStopViewWidth = 40.0f;
float const kStopCircleSize = 25.0f;

- (instancetype)initWithStop:(GBStop *)stop {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _stop = stop;
        
        UIColor *color = [UIColor colorWithHexString:stop.hexColor];
        UIImage *coloredCircle = [[self class] circleWithColor:color];
        
        _routeImageView = [[UIImageView alloc] init];
        _routeImageView.image = coloredCircle;
        _routeImageView.contentMode = UIViewContentModeCenter;
        _routeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_routeImageView];
        
        UIVisualEffectView *predictionsEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
        predictionsEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:predictionsEffectView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = stop.title;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [[predictionsEffectView contentView] addSubview:_nameLabel];
        
        _predictionsLabel = [[UILabel alloc] init];
        _predictionsLabel.text = @"Loading...";
        _predictionsLabel.textColor = RGBColor(184, 191, 195);
        _predictionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_predictionsLabel];
        
        _directionLabel = [[UILabel alloc] init];
        _directionLabel.text = [NSString stringWithFormat:@"Direction: %@", stop.direction.title];
        _directionLabel.textColor = RGBColor(184, 191, 195);
        _directionLabel.font = [UIFont systemFontOfSize:11];
        _directionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_directionLabel];
        
        
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_routeImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[predictionsEffectView(==_predictionsLabel)][_predictionsLabel][_directionLabel(==_predictionsLabel)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel, _directionLabel, predictionsEffectView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][_predictionsLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, _predictionsLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][predictionsEffectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, predictionsEffectView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][_directionLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, _directionLabel)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
        
        _imageHeightConstraint = [NSLayoutConstraint
                                  constraintWithItem:_routeImageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:0
                                  multiplier:0
                                  constant:GBStopViewWidth];
        _imageHeightConstraint.priority = UILayoutPriorityDefaultHigh;
        [constraints addObject:_imageHeightConstraint];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

+ (UIImage *)circleWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kStopCircleSize, kStopCircleSize), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(3, 3, kStopCircleSize - 6, kStopCircleSize - 6);
    
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(ctx, 2.0);
    CGContextFillEllipseInRect(ctx, rect);
    CGContextStrokeEllipseInRect(ctx, rect);
    
    CGContextRestoreGState(ctx);
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

@end
