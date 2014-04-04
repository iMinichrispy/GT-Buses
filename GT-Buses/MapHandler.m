//
//  MapHandler.m
//  GT-Buses
//
//  Created by Alex Perez on 2/1/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "MapHandler.h"
#define ROUTE_SETUP @{@"red":@"RedDot@2x.png", @"green":@"GreenDot@2x.png", @"blue":@"BlueDot@2x.png", @"trolley":@"YellowDot@2x.png", @"emory":@"RedDot@2x.png", @"night":@"RedDot@2x.png"}
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@implementation MapHandler

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *line = [[MKPolylineView alloc] initWithPolyline:overlay];
        line.strokeColor = ((BusRouteLine *)overlay).color;
        
        if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")))
            line.lineWidth = (IS_IPAD) ? 20 : 10;
        else
            line.lineWidth = (IS_IPAD) ? 12 : 6;
        
        line.alpha = .5;
        line.lineCap = kCGLineCapButt;
        return line;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        line.strokeColor = ((BusRouteLine *)overlay).color;
        line.lineWidth =  (IS_IPAD) ? 10 : 6;
        line.alpha = .5;
        line.lineCap = kCGLineCapButt;
        return line;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    else if ([annotation isKindOfClass:[BusAnnotation class]]) {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Nil];
        UIImage *arrowImage = [UIImage imageNamed:@"Arrow.png"];
        UIImage *colorArrowImage = [arrowImage imageWithColor:((BusAnnotation *)annotation).color];
        ((BusAnnotation *)annotation).arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 32)];
        ((BusAnnotation *)annotation).arrowImageView.image = colorArrowImage;
        [(BusAnnotation *)annotation updateHeading];
        [annotationView addSubview:((BusAnnotation *)annotation).arrowImageView];
        annotationView.frame = ((BusAnnotation *)annotation).arrowImageView.frame;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    else if ([annotation isKindOfClass:[BusStopAnnotation class]]) {
        int size = (IS_IPAD) ? 17 : 10;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Nil];
        annotationView.frame = CGRectMake(0, 0, size, size);
        annotationView.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        UIImage *dotImage = [UIImage imageNamed:@"Dot.png"];
        imageView.image = [dotImage imageWithColor:[((BusStopAnnotation *)annotation).color darkerColor:0.2]];
        imageView.alpha = .7;
        [annotationView addSubview:imageView];
        return annotationView;
    }
    else
        return nil;
}

@end
