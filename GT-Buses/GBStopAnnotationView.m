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
        
        _favoriteButton = [[GBFavoriteButton alloc] init];
        self.rightCalloutAccessoryView = _favoriteButton;
        
        _stopImageView = [[UIImageView alloc] init];
        _stopImageView.alpha = .7;
        [self addSubview:_stopImageView];
    }
    return self;
}

- (void)setupForAnnotation:(GBStopAnnotation *)annotation {
    [_favoriteButton setStop:annotation.stop];
    float size = IS_IPAD ? 17.0f : 10.0f;
    if ([[GBConfig sharedInstance] isParty]) size = size * 2;
    self.frame = CGRectMake(0, 0, size, size);
    
    UIColor *color = [annotation.stop.route.color darkerColor:0.2];
    _stopImageView.image = [UIImage circleImageWithColor:color size:self.frame.size.height];
    _stopImageView.frame = self.bounds;
}

@end
