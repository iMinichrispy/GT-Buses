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

float const GBStopViewHeight = 40.0f;
float const kStopCircleSize = 25.0f;

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

- (instancetype)initWithStop:(GBStop *)stop {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel(height)][predictionsEffectView(height)]|" options:0 metrics:@{@"height":@(GBStopViewHeight / 2)} views:NSDictionaryOfVariableBindings(_nameLabel, predictionsEffectView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView(width)][_nameLabel]|" options:0 metrics:@{@"width":@(GBStopViewHeight)} views:NSDictionaryOfVariableBindings(_routeImageView, _nameLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView(width)][predictionsEffectView]|" options:0 metrics:@{@"width":@(GBStopViewHeight)} views:NSDictionaryOfVariableBindings(_routeImageView, predictionsEffectView)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_predictionsLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_predictionsLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel)]];
        
//        [constraints addObject:[NSLayoutConstraint
//                                constraintWithItem:self
//                                attribute:NSLayoutAttributeHeight
//                                relatedBy:NSLayoutRelationEqual
//                                toItem:nil
//                                attribute:0
//                                multiplier:0
//                                constant:GBStopViewHeight]];
        [self addConstraints:constraints];
    }
    return self;
}

@end
