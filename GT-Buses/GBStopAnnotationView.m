//
//  GBStopAnnotationView.m
//  GT-Buses
//
//  Created by Alex Perez on 11/30/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBStopAnnotationView.h"

#import "GBStopAnnotation.h"
#import "GBConstants.h"
#import "GBConfig.h"
#import "GBColors.h"
#import "GBStop.h"
#import "GBRoute.h"
#import "GBImage.h"
#import "GBFavoriteButton.h"

@implementation GBStopAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        if (![annotation isKindOfClass:[GBStopAnnotation class]]) {
            [NSException raise:NSInvalidArgumentException format:@"GBStopAnnotationView requires annotation of class GBStopAnnotation"];
        }
        
        self.canShowCallout = YES;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            _favoriteButton = [[GBFavoriteButton alloc] init];
            self.rightCalloutAccessoryView = _favoriteButton;
        }
        
        _stopImageView = [[UIImageView alloc] init];
        _stopImageView.alpha = .9;
        [self addSubview:_stopImageView];
    }
    return self;
}

- (void)setupForAnnotation:(GBStopAnnotation *)annotation {
    [_favoriteButton setStop:annotation.stop];
    
    UIColor *color = annotation.stop.route.color;
    UIImage *circleImage = [UIImage circleStopImageWithColor:color];
    
    _stopImageView.image = circleImage;
    _stopImageView.frame = CGRectMake(0, 0, circleImage.size.width, circleImage.size.height);
    self.frame = _stopImageView.bounds;
}

@end
