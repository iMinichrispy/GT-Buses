//
//  MapHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 2/1/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBMapHandler.h"

#import "GBBusAnnotation.h"
#import "GBBusStopAnnotation.h"
#import "GBBusRouteLine.h"
#import "GBColors.h"
#import "GBConstants.h"

@implementation GBMapHandler

// For iOS <=6
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *line = [[MKPolylineView alloc] initWithPolyline:overlay];
        line.strokeColor = ((GBBusRouteLine *)overlay).color;
        line.lineWidth = 10;
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
        
        line.lineWidth =  lineWidth;
        line.lineCap = kCGLineCapButt;
        line.alpha = .5;
        return line;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[GBBusAnnotation class]]) {
        GBBusAnnotation *busAnnotation = (GBBusAnnotation *)annotation;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        UIImage *arrowImage = [UIImage imageNamed:@"Arrow"];
        UIImage *colorArrowImage = [arrowImage imageWithColor:busAnnotation.color];
        CGSize arrowSize = IS_IPAD ? CGSizeMake(48, 44) : CGSizeMake(35, 32);
        busAnnotation.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, arrowSize.width, arrowSize.height)];
        busAnnotation.arrowImageView.image = colorArrowImage;
        [busAnnotation updateArrowImageRotation];
        [annotationView addSubview:busAnnotation.arrowImageView];
        annotationView.frame = busAnnotation.arrowImageView.frame;
        annotationView.canShowCallout = NO;
        
#if DEBUG
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UILabel *identifierLabel = [[UILabel alloc] init];
            identifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
            identifierLabel.textColor = busAnnotation.color;
            identifierLabel.font = [UIFont systemFontOfSize:12];
            identifierLabel.text = busAnnotation.busIdentifier;
            identifierLabel.backgroundColor = [UIColor clearColor];
            [annotationView addSubview:identifierLabel];
            
            NSMutableArray *constraints = [NSMutableArray new];
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:identifierLabel
                                    attribute:NSLayoutAttributeCenterX
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:busAnnotation.arrowImageView
                                    attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                    constant:0.0]];
            [constraints addObject:[NSLayoutConstraint
                                    constraintWithItem:identifierLabel
                                    attribute:NSLayoutAttributeCenterY
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:busAnnotation.arrowImageView
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                    constant:0.0]];
            [annotationView addConstraints:constraints];
        }
#endif
        return annotationView;
    }
    else if ([annotation isKindOfClass:[GBBusStopAnnotation class]]) {
        float size = IS_IPAD ? 17.0f : 10.0f;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        annotationView.frame = CGRectMake(0, 0, size, size);
        annotationView.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        UIImage *dotImage = [UIImage imageNamed:@"Dot"];
        imageView.image = [dotImage imageWithColor:[((GBBusStopAnnotation *)annotation).color darkerColor:0.2]];
        imageView.alpha = .7;
        [annotationView addSubview:imageView];
        return annotationView;
    }
    return nil;
}

@end
