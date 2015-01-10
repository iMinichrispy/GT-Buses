//
//  GBAppDelegate.m
//  GT-Buses
//
//  Created by Alex Perez on 2/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAppDelegate.h"

#import "GBRootViewController.h"
#import "GBUserInterface.h"
#import "GBConstants.h"
#import "GBWindow.h"
#import "GBConfig.h"
#import "GBRequestConfig.h"
#import "NSUserDefaults+SharedDefaults.h"
#import "GBAgency.h"

@implementation GBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GBConfig sharedInstance].agency = [GBAgency georgiaTechAgency];
//    [GBConfig sharedInstance].adsEnabled = YES;
//    [GBConfig sharedInstance].adsVisible = YES;
//    [GBConfig sharedInstance].canSelectAgency = YES;
    
    self.viewController = [[GBRootViewController alloc] init];
    
#if !DEFAULT_IMAGE
    self.viewController.title = NSLocalizedString(@"GT_BUSES_TITLE", @"GT Buses main title");
#endif
    
    GBNavigationController *navController = [[GBNavigationController alloc] initWithRootViewController:self.viewController];
    
    self.window = [[GBWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (ROTATION_ENABLED) {
        // Don't allow rotation when settings is open since it interferes with the root view controller scale transform
        GBWindow *gbwindow = (GBWindow *)window;
        if (gbwindow.settingsVisible) {
            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            return UIInterfaceOrientationIsLandscape(statusBarOrientation) ? UIInterfaceOrientationMaskLandscape : (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
        }
        
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // Example: gtbuses://?agency=georgia-tech
    // Example: gtbuses://?agency=art&searchEnabled=1
    NSArray *components = [url.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *queryDictionary = [NSMutableDictionary new];
    
    for (NSString *pair in components) {
        NSArray *pairComponents = [pair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        queryDictionary[key] = value;
    }
    
    NSString *agencyTag = queryDictionary[@"agency"];
    if ([agencyTag length]) {
        GBConfig *sharedConfig = [GBConfig sharedInstance];
        if (sharedConfig.canSelectAgency) {
            NSDictionary *agenciesDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:GBUserDefaultsAgenciesKey];
            NSDictionary *agencyDictionary = agenciesDictionary[agencyTag];
            
            GBAgency *agency;
            if (agencyDictionary) {
                agency = [agencyDictionary xmlToAgency];
            } else {
                agency = [[GBAgency alloc] initWithTag:agencyTag];
                // If agency searchEnabled is hard-coded (as w/ Gatech), ignore the url parameter
                if (!agency.searchEnabled) {
                    agency.searchEnabled = [queryDictionary[@"searchEnabled"] boolValue];
                    
                    if (agency.searchEnabled) {
                        // If the agency is search enabled, we need to save this property for the next time the app loads
                        NSMutableDictionary *mutableAgencies = [agenciesDictionary mutableCopy];
                        if (!mutableAgencies) {
                            mutableAgencies = [NSMutableDictionary new];
                        }
                        mutableAgencies[agency.tag] = [agency toDictionary];
                        [[NSUserDefaults standardUserDefaults] setObject:mutableAgencies forKey:GBUserDefaultsAgenciesKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
            sharedConfig.agency = agency;
        }
        return YES;
    }
    
    return NO;
}

@end
