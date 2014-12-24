//
//  GBHorizontalLayout.m
//  GT-Buses
//
//  Created by Alex Perez on 12/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBHorizontalLayout.h"

#import "GBConstraintHelper.h"

#define SINGLE_SEGMENT_SIZE ((CGSize) {.height = 40.0, .width = 150.0})
#define MULTIPLE_SEGMENT_SIZE ((CGSize) {.height = 55.0, .width = 77.0})

double const kSegmentSpacing = 12.0;

@implementation GBHorizontalLayout

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)addSegments:(NSArray *)segments {
    NSInteger count = [segments count];
    
    if (count) {
        NSMutableArray *constraints = [NSMutableArray new];
        
        if (count == 1) {
            UIView *segment = [segments firstObject];
            [self addSubview:segment];
            
            [constraints addObject:[GBConstraintHelper widthConstraint:segment width:SINGLE_SEGMENT_SIZE.width]];
            [constraints addObject:[GBConstraintHelper heightConstraint:segment height:SINGLE_SEGMENT_SIZE.height]];
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:segment horizontal:YES]];
            [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:segment horizontal:NO]];
        } else {
            for (int i = 0; i < [segments count]; i++) {
                UIView *segment = segments[i];
                [self addSubview:segment];
                [constraints addObjectsFromArray:[GBConstraintHelper fillConstraint:segment horizontal:NO]];
                
                if (i != 0) {
                    UIView *leftView = segments[i - 1];
                    UIView *rightView = segment;
                    [constraints addObjectsFromArray:[GBConstraintHelper spacingConstraintFromLeftView:leftView toRightView:rightView spacing:kSegmentSpacing]];
                    [constraints addObject:[NSLayoutConstraint
                                            constraintWithItem:leftView
                                            attribute:NSLayoutAttributeWidth
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:rightView
                                            attribute:NSLayoutAttributeWidth
                                            multiplier:1.0 constant:0.0]];
                }
            }
            
            UIView *first = [segments firstObject];
            UIView *last = [segments lastObject];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[first]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(first)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[last]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(last)]];
            [constraints addObject:[GBConstraintHelper heightConstraint:self height:MULTIPLE_SEGMENT_SIZE.height]];
            [constraints addObject:[GBConstraintHelper widthConstraint:first width:MULTIPLE_SEGMENT_SIZE.width]];
        }
        [self addConstraints:constraints];
    }
}

@end
