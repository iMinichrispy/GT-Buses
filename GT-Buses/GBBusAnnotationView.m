//
//  GBBusAnnotationView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBusAnnotationView.h"

#import "GBBusAnnotation.h"
#import "GBImage.h"
#import "GBConfig.h"
#import "GBConstants.h"
#import "GBBus.h"
#import "GBColors.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface GBBusAnnotationView ()

@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *identifierLabel;

@end

@implementation GBBusAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        if (![annotation isKindOfClass:[GBBusAnnotation class]]) {
            [NSException raise:NSInvalidArgumentException format:@"GBBusAnnotationView requires annotation of class GBBusAnnotation"];
        }
        
        GBBusAnnotation *busAnnotation = (GBBusAnnotation *)annotation;
        GBBus *bus = busAnnotation.bus;
        
        UIImage *arrowImage = [UIImage arrowImageWithColor:bus.color];
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, arrowImage.size.width, arrowImage.size.height)];
        _arrowImageView.image = arrowImage;
        [self updateArrowImageRotation];
        [self addSubview:_arrowImageView];
        
        self.frame = _arrowImageView.bounds;
        self.canShowCallout = NO;
        
        [self setIdentifierVisible:[[GBConfig sharedInstance] showsBusIdentifiers]];
    }
    return self;
}

- (void)setupForAnnotation:(GBBusAnnotation *)annotation {
    // TODO: For reusable annotations, not yet working
    GBBus *bus = annotation.bus;
    UIImage *arrowImage = [UIImage arrowImageWithColor:bus.color];
    _arrowImageView.frame = CGRectMake(0, 0, arrowImage.size.width, arrowImage.size.height);
    _arrowImageView.image = arrowImage;
    
    if ([[GBConfig sharedInstance] showsBusIdentifiers]) {
        _identifierLabel.text = bus.identifier;
    }
}

- (void)updateArrowImageRotation {
    GBBus *bus = ((GBBusAnnotation *)self.annotation).bus;
    _arrowImageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(bus.heading));
}

- (void)setIdentifierVisible:(BOOL)visible {
    GBBus *bus = ((GBBusAnnotation *)self.annotation).bus;
    
    if (!_identifierLabel && visible) {
        _identifierLabel = [[UILabel alloc] init];
        _identifierLabel.textColor = [bus.color darkerColor:0.5];
        _identifierLabel.font = [UIFont boldSystemFontOfSize:12];
        _identifierLabel.text = bus.identifier;
        _identifierLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_identifierLabel];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _identifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
            NSMutableArray *constraints = [NSMutableArray new];
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:_identifierLabel
                                    attribute:NSLayoutAttributeCenterX
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:_arrowImageView
                                    attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                    constant:0.0]];
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:_identifierLabel
                                    attribute:NSLayoutAttributeCenterY
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:_arrowImageView
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                    constant:-10.0]];
            [self addConstraints:constraints];
        } else {
            // iOS 6 doesn't play nice with autolayout
            [_identifierLabel sizeToFit];
            _identifierLabel.center = CGPointMake(_arrowImageView.center.x, _arrowImageView.center.y - 20);
        }
    } else if (!visible) {
        [_identifierLabel removeFromSuperview];
        _identifierLabel = nil;
    }
}

@end
