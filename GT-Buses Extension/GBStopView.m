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
#import "GBRoute.h"
#import "GBStopGroup.h"

@import NotificationCenter;

@implementation GBStopView

float const GBStopViewImageViewHeight = 40.0f;
float const GBStopViewImageViewWidth = 35.0f;
float const kStopCircleSize = 25.0f;

- (instancetype)initWithStop:(GBStop *)stop {
    GBStopGroup *stopGroup = [[GBStopGroup alloc] initWithStop:stop];
    self = [self initWithStopGroup:stopGroup];
    return self;
}

- (instancetype)initWithStopGroup:(GBStopGroup *)stopGroup {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _stopGroup = stopGroup;
        
        UIImage *coloredCircle = [[self class] circlesWithStopGroup:_stopGroup];
        
        _routeImageView = [[UIImageView alloc] init];
        _routeImageView.image = coloredCircle;
        _routeImageView.contentMode = UIViewContentModeCenter;
        _routeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_routeImageView];
        
        UIVisualEffectView *predictionsEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
        predictionsEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:predictionsEffectView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = [_stopGroup firstStop].title;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [[predictionsEffectView contentView] addSubview:_nameLabel];
        
        _predictionsLabel = [[UILabel alloc] init];
        _predictionsLabel.numberOfLines = 0;
        _predictionsLabel.text = @"Loading...";
        _predictionsLabel.textColor = RGBColor(184, 191, 195);
        _predictionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_predictionsLabel];
        
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.font = [UIFont systemFontOfSize:13];
        _distanceLabel.text = (stopGroup.distance) ? [[self class] stringWithDistance:_stopGroup.distance] : @"";
        _distanceLabel.textColor = RGBColor(184, 191, 195);
        _distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_distanceLabel];
        
        _directionLabel = [[UILabel alloc] init];
        _directionLabel.text = [NSString stringWithFormat:@"To %@", [_stopGroup firstStop].direction.title];
        _directionLabel.textColor = RGBColor(184, 191, 195);
        _directionLabel.font = [UIFont systemFontOfSize:11];
        _directionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_directionLabel];
        
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_routeImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[predictionsEffectView][_predictionsLabel]-2-[_directionLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel, _directionLabel, predictionsEffectView)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[predictionsEffectView][_distanceLabel]-2-[_directionLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel, _directionLabel, predictionsEffectView, _distanceLabel)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][_predictionsLabel][_distanceLabel(>=35)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, _predictionsLabel, _distanceLabel)]];
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
                                  constant:GBStopViewImageViewWidth];
        _imageHeightConstraint.priority = UILayoutPriorityDefaultHigh;
        [constraints addObject:_imageHeightConstraint];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
}

+ (UIImage *)circlesWithStopGroup:(GBStopGroup *)stopGroup {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(GBStopViewImageViewWidth, GBStopViewImageViewHeight), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    float y = 2;
    for (GBStop *stop in stopGroup.stops) {
        CGRect rect = CGRectMake(3, y, kStopCircleSize - 6, kStopCircleSize - 6);
        
        CGContextSetFillColorWithColor(ctx, stop.route.color.CGColor);
        
        CGContextFillEllipseInRect(ctx, rect);
        CGContextStrokeEllipseInRect(ctx, rect);
        y += 12;
    }
    
    CGContextRestoreGState(ctx);
    UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBStopView StopGroup: %@>", _stopGroup];
}

- (void)setPredictions:(NSString *)predictions forStop:(GBStop *)stop {
    stop.predictions = predictions;
    [self updatePredictionsLabelText];
}

- (void)updatePredictionsLabelText {
    NSString *predictionsLabelText = @"";
    
    if ([_stopGroup.stops count] == 1) {
        GBStop *stop = [_stopGroup.stops firstObject];
        NSString *stopPredictions = (stop.predictions) ? stop.predictions : @"";
        predictionsLabelText = [predictionsLabelText stringByAppendingFormat:@"%@", stopPredictions];
    } else {
        GBStop *lastStop = [_stopGroup.stops lastObject];
        for (GBStop *stop in _stopGroup.stops) {
            NSString *stopPredictions = (stop.predictions) ? stop.predictions : @"";
            predictionsLabelText = [predictionsLabelText stringByAppendingFormat:(stop == lastStop) ? @"%@: %@" : @"%@: %@, ", stop.route.title, stopPredictions];
        }
    }
    
    _predictionsLabel.text = predictionsLabelText;
}

+ (NSString *)stringWithDistance:(double)distance {
    static MKDistanceFormatter *distanceFormatter;
    if (!distanceFormatter) {
        distanceFormatter = [[MKDistanceFormatter alloc]init];
        distanceFormatter.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
    }
    return [distanceFormatter stringFromDistance:distance];
}

@end
