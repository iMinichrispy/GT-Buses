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

@implementation GBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.viewController = [[GBRootViewController alloc] init];
    self.viewController.searchEnaled = YES;
    
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

@end
