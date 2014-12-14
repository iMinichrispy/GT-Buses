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
@property (nonatomic, strong) NSString *iOSVersion;

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
        // agency
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        _iOSVersion = info[@"CFBundleShortVersionString"];
        _version = 1;
        _party = NO;
        _message = @"";
        // update to new version?
        
        _buildingsVersion = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsBuildingsVersionKey];
        
        _showsArrivalTime = [[NSUserDefaults sharedDefaults] boolForKey:GBSharedDefaultsShowsArrivalTimeKey];
        
        _showsBusIdentifiers = [[NSUserDefaults standardUserDefaults] boolForKey:GBUserDefaultsShowsBusIdentifiersKey];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Config version: %li, message: %@>", (long)_version, _message];
}

- (void)handleConfig:(NSDictionary *)config {
    if (config) {
        NSInteger version = [config[@"version"] integerValue];
        NSString *iOSVersion = config[@"iOSVersion"];
        NSString *message = config[@"message"];
        
        NSInteger buildingVersion = [config[@"buildingsVersion"] integerValue];
        
        BOOL party = [config[@"party"] boolValue];
        
        [self setVersion:version];
        [self setBuildingsVersion:buildingVersion];
        
        if (![_message isEqualToString:message]) {
            [self setMessage:message];
        }
        if (![_iOSVersion isEqualToString:iOSVersion]) {
            [self setIOSVersion:iOSVersion];
        }
        
        [self setParty:party];
    }
}
- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = message;
        
        if ([_message isEqualToString:message]) {
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationMessageDidChange object:message];
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

- (void)setIOSVersion:(NSString *)iOSVersion {
    if (_iOSVersion != iOSVersion) {
        _iOSVersion = iOSVersion;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationiOSVersionDidChange object:iOSVersion];
    }
}

- (void)setShowsArrivalTime:(BOOL)showsArrivalTime {
    if (_showsArrivalTime != showsArrivalTime) {
        _showsArrivalTime = showsArrivalTime;
        [[NSUserDefaults sharedDefaults] setBool:_showsArrivalTime forKey:GBSharedDefaultsShowsArrivalTimeKey];
        [[NSUserDefaults sharedDefaults] synchronize];
    }
}

- (void)setShowsBusIdentifiers:(BOOL)showsBusIdentifiers {
    if (_showsBusIdentifiers != showsBusIdentifiers) {
        _showsBusIdentifiers = showsBusIdentifiers;
        [[NSUserDefaults standardUserDefaults] setBool:_showsBusIdentifiers forKey:GBUserDefaultsShowsBusIdentifiersKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationShowsBusIdentifiersDidChange object:nil];
    }
}

- (void)setBuildingsVersion:(NSInteger)buildingsVersion {
    if (_buildingsVersion != buildingsVersion) {
        _buildingsVersion = buildingsVersion;
        // Don't update NSUserDefaults here because saved buildings version should only be saved once new buildings are retrieved and stored
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationBuildingsVersionDidChange object:nil];
    }
}

- (BOOL)updateAvailable {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = info[@"CFBundleShortVersionString"];
    return ([_iOSVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending);
}

@end
