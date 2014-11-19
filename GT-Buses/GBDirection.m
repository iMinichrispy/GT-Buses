//
//  GBDirection.m
//  GT-Buses
//
//  Created by Alex Perez on 11/16/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBDirection.h"

@implementation NSDictionary (GBDirection)

- (GBDirection *)toDirection {
    GBDirection *direction = [[GBDirection alloc] initWithTitle:self[@"title"] tag:self[@"tag"]];
    direction.oneDirection = [self[@"oneDirection"] boolValue];
    return direction;
}

@end

@implementation GBDirection

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag {
    self = [super init];
    if (self) {
        _title = title;
        _tag = tag;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{@"title":_title, @"tag":_tag, @"oneDirection":@(_oneDirection)};
    return dictionary;
}

@end
