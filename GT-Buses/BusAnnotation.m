//
//  BusAnnotation.m
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "BusAnnotation.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation BusAnnotation
@synthesize busIdentifier;
@synthesize heading;
@synthesize color;
@synthesize arrowImageView;

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self.busIdentifier isEqualToString:((BusAnnotation *)other).busIdentifier];
}

- (void)updateHeading {
    self.arrowImageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(self.heading));
}

@end
