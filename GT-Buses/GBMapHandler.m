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
#import "GBBusAnnotationView.h"
#import "GBStopAnnotationView.h"
#import "GBConfig.h"
#import "GBConstants.h"

@implementation GBMapHandler

static NSString *const GBStopAnnotationIdentifier = @"GBStopAnnotationIdentifier";
static NSString *const GBBusAnnotationIdentifier = @"GBBusAnnotationIdentifier";

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
        // TODO: Switch to reuseable annotation views
        GBBusAnnotationView *annotationView = [[GBBusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GBBusAnnotationIdentifier];
        return annotationView;
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

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *annotationView in views) {
        // Ensures bus annotation is added above stops
        if ([annotationView isKindOfClass:[GBBusAnnotationView class]]) {
            [[annotationView superview] bringSubviewToFront:annotationView];
        } else {
            // Since buses and stops are never added simultaneously, break if the first annotation is not a bus annotation
            break;
        }
    }
}

@end
