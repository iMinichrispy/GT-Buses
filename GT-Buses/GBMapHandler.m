//
//  GBMapHandler.m
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
#import "GBConfig.h"
#import "GBFavoriteButton.h"
#import "GBStop.h"
#import "GBRoute.h"

@implementation GBMapHandler

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
        
        if ([[GBConfig sharedInstance] isParty]) {
            lineWidth *= 2;
        }
        
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
#warning use reuse identifier?
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        CGSize arrowSize = IS_IPAD ? CGSizeMake(24, 32) : CGSizeMake(18, 24);
        if ([[GBConfig sharedInstance] isParty]) {
            arrowSize = CGSizeMake(arrowSize.width * 4, arrowSize.height * 4);
        }
        UIImage *colorArrowImage = [[self class] arrowImageWithColor:busAnnotation.color size:arrowSize];
        busAnnotation.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, arrowSize.width, arrowSize.height)];
        busAnnotation.arrowImageView.image = colorArrowImage;
        [busAnnotation updateArrowImageRotation];
        [annotationView addSubview:busAnnotation.arrowImageView];
        annotationView.frame = busAnnotation.arrowImageView.bounds;
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
        if ([[GBConfig sharedInstance] isParty]) {
            size = size * 2;
        }
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        annotationView.frame = CGRectMake(0, 0, size, size);
        annotationView.canShowCallout = YES;
        
        GBBusStopAnnotation *stopAnnotation = (GBBusStopAnnotation *)annotation;
        UIButton *favoriteButton = [[GBFavoriteButton alloc] initWithBusStopAnnotation:stopAnnotation];
        annotationView.rightCalloutAccessoryView = favoriteButton;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        UIColor *color = [((GBBusStopAnnotation *)annotation).stop.route.color darkerColor:0.2];
        imageView.image = [[self class] circleImageWithColor:color size:size];
        imageView.alpha = .7;
        [annotationView addSubview:imageView];
        return annotationView;
    }
    return nil;
}

+ (UIImage *)arrowImageWithColor:(UIColor *)color size:(CGSize)size {
    // Saves the dot image so only one needs to be created per color & size
    static NSMutableDictionary *arrowImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrowImages = [[NSMutableDictionary alloc] init];
    });
    
    id <NSCopying> key = @([color hash] + size.width);
    UIImage *image = arrowImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        CGContextSetLineWidth(context, 1.0);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGPathMoveToPoint(pathRef, NULL, 0.0, size.height); // Bottom left
        CGPathAddLineToPoint(pathRef, NULL, size.width / 2, 0.0); // Top of arrow
        CGPathAddLineToPoint(pathRef, NULL, size.width, size.height); // Bottom right
        CGPathAddLineToPoint(pathRef, NULL, size.width / 2, .71 * size.height); // Center
        CGPathAddLineToPoint(pathRef, NULL, 0.0, size.height); // Bottom left
        CGPathCloseSubpath(pathRef);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        arrowImages[key] = image;
    }
    
    
    return image;
}


+ (UIImage *)circleImageWithColor:(UIColor *)color size:(float)size {
    // Saves the dot image so only one needs to be created per color & size
    static NSMutableDictionary *circleImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        circleImages = [[NSMutableDictionary alloc] init];
    });
    
    id <NSCopying> key = @([color hash] + size);
    UIImage *image = circleImages[key];
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextSetLineWidth(ctx, 2.0);
        CGRect rect = CGRectMake(0, 0, size, size);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        circleImages[key] = image;
    }
    
    return image;
}

+ (float)circleSize {
    return IS_IPAD ? 17.0f : 10.0f;
}

@end
