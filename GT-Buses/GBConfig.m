//
//  GBConfig.m
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConfig.h"

#import "GBConstants.h"

@interface GBConfig ()

@property (nonatomic) NSInteger version;

@end

@implementation GBConfig

+ (instancetype)sharedInstance {
    static GBConfig *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Check user defaults?
        _version = 1;
        _party = NO;
        // update to new version?
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Config version: %li>", (long)_version];
}

- (void)handleConfig:(NSDictionary *)config {
//    NSLog(@"%@",config);
    if (config) {
        NSInteger newVersion = [config[@"version"] integerValue];
        BOOL party = [config[@"party"] boolValue];
        
        if (_party != party) {
            _party = party;
            // toggle party
            [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationPartyModeDidChange object:nil];
        }
        
        if (_version != newVersion) {
//            _baseURL = config[@"baseURL"];
        }
    }
}

@end
