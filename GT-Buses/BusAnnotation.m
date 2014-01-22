//
//  BusAnnotation.m
//  GT-Buses
//
//  Created by Alex Perez on 1/31/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "BusAnnotation.h"

@implementation BusAnnotation
@synthesize busIdentifier;
@synthesize heading;

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self.busIdentifier isEqualToString:((BusAnnotation *)other).busIdentifier];
}

@end
