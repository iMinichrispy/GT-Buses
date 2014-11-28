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
        
        UIButton *favoriteButton = [[GBFavoriteButton alloc] initWithBusStopAnnotation:annotation];
        self.rightCalloutAccessoryView = favoriteButton;
        
        GBStopAnnotation *stopAnnotation = (GBStopAnnotation *)annotation;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        UIColor *color = [stopAnnotation.stop.route.color darkerColor:0.2];
        imageView.image = [UIImage circleImageWithColor:color size:size];
        imageView.alpha = .7;
        [self addSubview:imageView];
    }
    return self;
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
#warning dequeue annotations
//        [mapView dequeueReusableAnnotationViewWithIdentifier:<#(NSString *)#>];
        GBBusAnnotationView *annotationView = [[GBBusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GBBusAnnotationIdentifier];
        return annotationView;
    }
    else if ([annotation isKindOfClass:[GBStopAnnotation class]]) {
        GBStopAnnotationView *annotationView = [[GBStopAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GBStopAnnotationIdentifier];
        return annotationView;
    }
    return nil;
}

@end
