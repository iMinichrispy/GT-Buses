//
//  AppDelegate.m
//  GT-Buses
//
//  Created by Alex Perez on 2/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"
#import "AboutController.h"
#import "MFSideMenu.h"
#import "GBConstants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[RootViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    AboutController *aboutController = [[AboutController alloc] init];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navController leftMenuViewController:aboutController rightMenuViewController:nil];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];

    [self registerDefaults];
    return YES;
}

- (void)registerDefaults {
    NSString *defaultPath = [[NSBundle mainBundle] pathForResource:GBUserDefaultsFilePath ofType:@"plist"];
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

@end
