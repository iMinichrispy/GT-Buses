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
#import "GBAboutController.h"
#import "GBConstants.h"
#import "MFSideMenu.h"

@implementation GBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.viewController = [[GBRootViewController alloc] init];
    
    GBNavigationController *navController = [[GBNavigationController alloc] initWithRootViewController:self.viewController];
    GBAboutController *aboutController = [[GBAboutController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navController leftMenuViewController:aboutController rightMenuViewController:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    static UIInterfaceOrientationMask orientationMask;
    if (!orientationMask) {
        orientationMask = (ROTATION_ENABLED) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    }
    return orientationMask;
}

@end
