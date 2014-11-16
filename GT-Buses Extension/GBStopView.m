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
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = stop.title;
//        _nameLabel.textColor = color;
//        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textColor = RGBColor(184, 191, 195);
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_nameLabel];
        
        
        UIVisualEffectView *predictionsEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
        predictionsEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:predictionsEffectView];

        _predictionsLabel = [[UILabel alloc] init];
        _predictionsLabel.text = @"Loading...";
        _predictionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [[predictionsEffectView contentView] addSubview:_predictionsLabel];
        
        
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_routeImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][predictionsEffectView(==_nameLabel)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, predictionsEffectView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, _nameLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][predictionsEffectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, predictionsEffectView)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_predictionsLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_predictionsLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel)]];
        
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
        [self addConstraints:constraints];
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
