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
        
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
        _showsArrivalTime = [shared boolForKey:GBSharedDefaultsShowsArrivalTimeKey];
        
        _showsBusIdentifiers = [[NSUserDefaults standardUserDefaults] boolForKey:GBUserDefaultsShowsBusIdentifiers];
        
//#if DEBUG
//        _showBusIdentifiers = YES;
//#else
//        _showBusIdentifiers = NO; // check settigns defaults, also requires ios 7!!!
//#endif
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
#warning could be 0
        
    }
}

- (void)setIOSVersion:(NSString *)iOSVersion {
    if (_iOSVersion != iOSVersion) {
        _iOSVersion = iOSVersion;
        
        // iOS Version did change
        // If ios version > current ios version
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationiOSVersionDidChange object:iOSVersion];
    }
}

- (void)setShowsArrivalTime:(BOOL)showsArrivalTime {
    if (_showsArrivalTime != showsArrivalTime) {
        _showsArrivalTime = showsArrivalTime;
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:GBSharedDefaultsExtensionSuiteName];
        [shared setBool:_showsArrivalTime forKey:GBSharedDefaultsShowsArrivalTimeKey];
        [shared synchronize];
    }
}

- (void)setShowsBusIdentifiers:(BOOL)showsBusIdentifiers {
    if (_showsBusIdentifiers != showsBusIdentifiers) {
        _showsBusIdentifiers = showsBusIdentifiers;
        [[NSUserDefaults standardUserDefaults] setBool:_showsBusIdentifiers forKey:GBUserDefaultsShowsBusIdentifiers];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationShowsBusIdentifiersDidChange object:nil];
    }
}

- (void)setBuildingsVersion:(NSInteger)buildingsVersion {
    if (_buildingsVersion != buildingsVersion) {
        _buildingsVersion = buildingsVersion;
#warning should only set saved buildings version once new buildings are retrived and stored
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationBuildingsVersionDidChange object:nil];
    }
}

- (BOOL)updateAvailable {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = info[@"CFBundleShortVersionString"];
    return ([_iOSVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending);
}

@end
