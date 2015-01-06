//
//  GBAgency.m
//  GT-Buses
//
//  Created by Alex Perez on 12/17/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAgency.h"

NSString *const GBGeorgiaTechAgencyTag = @"georgia-tech";

// TODO: Enable search for non-georgia tech agencies

@implementation NSDictionary (GBAgency)

- (GBAgency *)xmlToAgency {
    GBAgency *agency = [[GBAgency alloc] initWithTitle:self[@"title"] tag:self[@"tag"] regionTitle:self[@"regionTitle"]];
    return agency;
}

@end

@implementation GBAgency

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag regionTitle:(NSString *)regionTitle {
    self = [super init];
    if (self) {
        _title = title;
        _tag = tag;
        _regionTitle = regionTitle;
        _searchEnabled = ([tag isEqualToString:GBGeorgiaTechAgencyTag]);
    }
    return self;
}

+ (GBAgency *)georgiaTechAgency {
    GBAgency *agency = [[GBAgency alloc] initWithTitle:@"Georgia Tech" tag:GBGeorgiaTechAgencyTag regionTitle:@"Georgia"];
    return agency;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBAgency title: %@, tag: %@, regionTitle: %@", _title, _tag, _regionTitle];
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    return [_tag isEqualToString:((GBAgency *)object).tag];
}

@end
