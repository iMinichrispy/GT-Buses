//
//  GBAgency.m
//  GT-Buses
//
//  Created by Alex Perez on 12/17/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAgency.h"

NSString *const GBGeorgiaTechAgencyTag = @"georgia-tech";

// TODO: Make region custom to each agency

@implementation NSDictionary (GBAgency)

- (GBAgency *)xmlToAgency {
    GBAgency *agency = [[GBAgency alloc] initWithTag:self[@"tag"]];
    agency.title = self[@"title"];
    agency.regionTitle = self[@"regionTitle"];
    NSString *shortTitle = self[@"shortTitle"];
    agency.shortTitle = ([shortTitle length]) ? shortTitle : agency.title;
    agency.searchEnabled = [self[@"searchEnabled"] boolValue];
    return agency;
}

@end

@implementation GBAgency

- (instancetype)initWithTag:(NSString *)tag {
    self = [super init];
    if (self) {
        _tag = tag;
        _searchEnabled = ([tag isEqualToString:GBGeorgiaTechAgencyTag]);
    }
    return self;
}

+ (GBAgency *)georgiaTechAgency {
    GBAgency *agency = [[GBAgency alloc] initWithTag:GBGeorgiaTechAgencyTag];
    return agency;
}

- (NSDictionary *)toDictionary {
    // Should really only be used when loading from URL scheme
    return @{@"tag":_tag, @"searchEnabled":@(_searchEnabled)};
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
