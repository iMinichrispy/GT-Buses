//
//  GBMapHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 2/1/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBMapHandler.h"

#import "GBBusAnnotation.h"
#import "GBStopAnnotation.h"
#import "GBBusRouteLine.h"
#import "GBColors.h"
#import "GBConstants.h"
#import "GBConfig.h"
#import "GBFavoriteButton.h"
#import "GBStop.h"
#import "GBRoute.h"
#import "GBImage.h"
#import "GBBusAnnotationView.h"

@interface GBStopAnnotationView : MKAnnotationView

@property (nonatomic, strong) GBFavoriteButton *favoriteButton;
@property (nonatomic, strong) UIImageView *stopImageView;

- (void)setupForAnnotation:(GBStopAnnotation *)annotation;

@end

@implementation GBStopAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        if (![annotation isKindOfClass:[GBStopAnnotation class]]) {
            [NSException raise:NSInvalidArgumentException format:@"GBStopAnnotationView requires annotation of class GBStopAnnotation"];
        }
        
        float size = IS_IPAD ? 17.0f : 10.0f;
        if ([[GBConfig sharedInstance] isParty]) size = size * 2;
        self.frame = CGRectMake(0, 0, size, size);
        self.canShowCallout = YES;
        
        _favoriteButton = [[GBFavoriteButton alloc] init];
        self.rightCalloutAccessoryView = _favoriteButton;
        
        _stopImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _stopImageView.alpha = .7;
        [self addSubview:_stopImageView];
    }
    return self;
}

- (void)setupForAnnotation:(GBStopAnnotation *)annotation {
    [_favoriteButton setStop:annotation.stop];
    UIColor *color = [annotation.stop.route.color darkerColor:0.2];
    _stopImageView.image = [UIImage circleImageWithColor:color size:self.frame.size.height];
}

@end


@implementation GBMapHandler

static NSString * const GBStopAnnotationIdentifier = @"GBStopAnnotationIdentifier";
static NSString * const GBBusAnnotationIdentifier = @"GBBusAnnotationIdentifier";

// For iOS <=6
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *line = [[MKPolylineView alloc] initWithPolyline:overlay];
        line.strokeColor = ((GBBusRouteLine *)overlay).color;
        line.lineWidth = (([[GBConfig sharedInstance] isParty])) ? 20 : 10;
        line.lineCap = kCGLineCapButt;
        line.alpha = .5;
        return line;
    }
    return nil;
}

// For iOS >=7
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        line.strokeColor = ((GBBusRouteLine *)overlay).color;
        
        float lineWidth;
        if (IS_IPAD) lineWidth = 9;
        else lineWidth = ([[UIScreen mainScreen] bounds].size.height >= 735) ? 4 : 6;
        
        if ([[GBConfig sharedInstance] isParty]) lineWidth *= 2;
        
        line.lineWidth =  lineWidth;
        line.lineCap = kCGLineCapButt;
        line.alpha = .5;
        return line;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[GBBusAnnotation class]]) {
        GBBusAnnotationView *annotationView = [[GBBusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GBBusAnnotationIdentifier];
        return annotationView;
        
//        GBBusAnnotationView *annotationView = (GBBusAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GBBusAnnotationIdentifier];
//        if (!annotationView) {
//            annotationView = [[GBBusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GBBusAnnotationIdentifier];
//        }
//#warning untested
//        [annotationView setupForAnnotation:annotation];
//        return annotationView;
    }
    else if ([annotation isKindOfClass:[GBStopAnnotation class]]) {
        GBStopAnnotationView *annotationView = (GBStopAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GBStopAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[GBStopAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GBStopAnnotationIdentifier];
        }
        [annotationView setupForAnnotation:annotation];
        return annotationView;
    }
    return nil;
}

@end
