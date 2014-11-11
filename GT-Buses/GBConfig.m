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
        _message = @"";
        // update to new version?
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Config version: %li, message: %@>", (long)_version, _message];
}

- (void)handleConfig:(NSDictionary *)config {
    NSLog(@"%@",config);
    if (config) {
        NSInteger version = [config[@"version"] integerValue];
        NSString *message = config[@"message"];
        BOOL party = [config[@"party"] boolValue];
        
        [self setMessage:message];
        [self setParty:party];
        [self setVersion:version];
    }
}
- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationMessageDidChange object:nil];
    }
}

- (void)setParty:(BOOL)party {
    if (_party != party) {
        _party = party;
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationPartyModeDidChange object:nil];
    }
}

- (void)setVersion:(NSInteger)version {
    if (_version != version) {
        _version = version;
    }
}

@end
