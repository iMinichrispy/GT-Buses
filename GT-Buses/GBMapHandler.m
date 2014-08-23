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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *line = [[MKPolylineView alloc] initWithPolyline:overlay];
        line.strokeColor = ((GBBusRouteLine *)overlay).color;
        line.lineWidth = (IS_IPAD) ? 20 : 10;
        line.alpha = .5;
        line.lineCap = kCGLineCapButt;
        return line;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        line.strokeColor = ((GBBusRouteLine *)overlay).color;
        line.lineWidth =  (IS_IPAD) ? 10 : 6;
        line.alpha = .5;
        line.lineCap = kCGLineCapButt;
        return line;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[GBBusAnnotation class]]) {
        GBBusAnnotation *busAnnotation = (GBBusAnnotation *)annotation;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        UIImage *arrowImage = [UIImage imageNamed:@"Arrow.png"];
        UIImage *colorArrowImage = [arrowImage imageWithColor:busAnnotation.color];
        busAnnotation.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 32)];
        busAnnotation.arrowImageView.image = colorArrowImage;
        [busAnnotation updateHeading];
        [annotationView addSubview:busAnnotation.arrowImageView];
        annotationView.frame = busAnnotation.arrowImageView.frame;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    else if ([annotation isKindOfClass:[GBBusStopAnnotation class]]) {
        float size = (IS_IPAD) ? 17.0f : 10.0f;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        annotationView.frame = CGRectMake(0, 0, size, size);
        annotationView.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        UIImage *dotImage = [UIImage imageNamed:@"Dot.png"];
        imageView.image = [dotImage imageWithColor:[((GBBusStopAnnotation *)annotation).color darkerColor:0.2]];
        imageView.alpha = .7;
        [annotationView addSubview:imageView];
        return annotationView;
    }
    return nil;
}

@end
