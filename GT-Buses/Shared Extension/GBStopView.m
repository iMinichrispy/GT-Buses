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
#import "GBImage.h"
#import "GBLabelEffectView.h"

@import NotificationCenter;

@implementation GBStopView

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
        
        UIImage *coloredCircle = [UIImage circlesWithStopGroup:_stopGroup];
        
        _routeImageView = [[UIImageView alloc] init];
        _routeImageView.image = coloredCircle;
        _routeImageView.contentMode = UIViewContentModeCenter;
        _routeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_routeImageView];
        
        GBLabelEffectView *nameEffectView = [[GBLabelEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
        nameEffectView.textLabel.text = [_stopGroup firstStop].title;
        nameEffectView.textLabel.textColor = [UIColor grayExtensionTextColor];
        _nameLabel = nameEffectView.textLabel;
        [self addSubview:nameEffectView];
        
        _predictionsLabel = [[UILabel alloc] init];
        _predictionsLabel.numberOfLines = 0;
        _predictionsLabel.text =NSLocalizedString(@"LOADING", @"Loading...");
        _predictionsLabel.textColor = RGBColor(220, 220, 220);
        _predictionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_predictionsLabel];
        
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.font = [UIFont systemFontOfSize:13];
        _distanceLabel.text = (stopGroup.distance) ? [[self class] stringWithDistance:_stopGroup.distance] : @"";
        _distanceLabel.textColor = [UIColor grayExtensionTextColor];
        _distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _distanceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_distanceLabel];
        
        _directionLabel = [[UILabel alloc] init];
        _directionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TO_DIRECTION", @"To [Direction]"), [_stopGroup firstStop].direction.title];
        [NSString localizedStringWithFormat:NSLocalizedString(@"TO_DIRECTION", @"To [Direction]"), [_stopGroup firstStop].direction.title];
        _directionLabel.textColor = [UIColor grayExtensionTextColor];
        _directionLabel.font = [UIFont systemFontOfSize:11];
        _directionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_directionLabel];
        
        NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_routeImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameEffectView][_predictionsLabel]-2-[_directionLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel, _directionLabel, nameEffectView)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameEffectView][_distanceLabel]-2-[_directionLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_predictionsLabel, _directionLabel, nameEffectView, _distanceLabel)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][_predictionsLabel]-[_distanceLabel(>=35)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, _predictionsLabel, _distanceLabel)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][nameEffectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, nameEffectView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_routeImageView][_directionLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_routeImageView, _directionLabel)]];
        
        _imageHeightConstraint = [NSLayoutConstraint
                                  constraintWithItem:_routeImageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:0
                                  multiplier:0
                                  constant:coloredCircle.size.width];
        _imageHeightConstraint.priority = UILayoutPriorityDefaultHigh;
        [constraints addObject:_imageHeightConstraint];
        [NSLayoutConstraint activateConstraints:constraints];
    }
    return self;
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
            predictionsLabelText = [predictionsLabelText stringByAppendingFormat:(stop == lastStop) ? @"%@: %@" : @"%@: %@, ", stop.route.shortTitle, stopPredictions];
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
