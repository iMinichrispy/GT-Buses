//
//  GBConfig.m
//  GT-Buses
//
//  Created by Alex Perez on 11/7/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBConfig.h"

#import "GBConstants.h"
#import "GBRequestConfig.h"
#import "GBAgency.h"

@interface GBConfig ()

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
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        _iOSVersion = info[@"CFBundleShortVersionString"];
        _party = NO;
        _message = @"";
        
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        _showsBusIdentifiers = [standardDefaults boolForKey:GBUserDefaultsShowsBusIdentifiersKey];
        
        NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
        
        NSString *agencyTag = [sharedDefaults objectForKey:GBSharedDefaultsAgencyKey];
        if ([agencyTag length]) {
            NSDictionary *agenciesDictionary = [standardDefaults objectForKey:GBUserDefaultsAgenciesKey];
            NSDictionary *agencyDictionary = agenciesDictionary[agencyTag];
            GBAgency *agency = [agencyDictionary xmlToAgency];
            if (agency) {
                _agency = agency;
            } else {
                _agency = [[GBAgency alloc] initWithTag:agencyTag];
            }
        }
        
        _requestConfig = [[GBRequestConfig alloc] initWithAgency:_agency.tag];
        _showsArrivalTime = [sharedDefaults boolForKey:GBSharedDefaultsShowsArrivalTimeKey];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBConfig Agency: %@, iOSVersion: %@, Party: %d, ShowsArrivalTime: %d, ShowsBusIds: %d, Message: %@>", _agency, _iOSVersion, _party, _showsArrivalTime, _showsBusIdentifiers, _message];
}

- (void)handleConfig:(NSDictionary *)config {
    if (config) {
        NSString *iOSVersion = config[@"iOSVersion"];
        NSString *message = config[@"message"];
        BOOL party = [config[@"party"] boolValue];
        
        if (![_message isEqualToString:message]) {
            [self setMessage:message];
        }
        if (![_iOSVersion isEqualToString:iOSVersion]) {
            [self setIOSVersion:iOSVersion];
        }
        
        [self setParty:party];
    }
}

- (void)setAgency:(GBAgency *)agency {
    if (_agency != agency) {
        BOOL newAgency;
        if (![_agency isEqual:agency]) {
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setObject:nil forKey:GBUserDefaultsSelectedRouteKey];
            [standardDefaults synchronize];
            
            NSUserDefaults *sharedDefaults = [NSUserDefaults sharedDefaults];
            // If the user switches agencies, clear the disabled routes
            [sharedDefaults setObject:nil forKey:GBSharedDefaultsDisabledRoutesKey];
            [sharedDefaults setObject:nil forKey:GBSharedDefaultsFavoriteStopsKey];
            [sharedDefaults setObject:nil forKey:GBSharedDefaultsRoutesKey];
            
            [sharedDefaults setObject:agency.tag forKey:GBSharedDefaultsAgencyKey];
            [sharedDefaults synchronize];
            
            newAgency = YES;
        }
        _agency = agency;
        _requestConfig = [[GBRequestConfig alloc] initWithAgency:agency.tag];
        
        if (newAgency) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationAgencyDidChange object:nil];
        }
    }
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationMessageDidChange object:message];
    }
}

- (void)setParty:(BOOL)party {
    if (_party != party) {
        _party = party;
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationPartyModeDidChange object:nil];
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

- (void)setAdsVisible:(BOOL)adsVisible {
    if (_adsVisible != adsVisible) {
        _adsVisible = adsVisible;
        [[NSNotificationCenter defaultCenter] postNotificationName:GBNotificationAdsVisibleDidChange object:nil];
    }
}

- (BOOL)updateAvailable {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = info[@"CFBundleShortVersionString"];
    return ([_iOSVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending);
}

@end
