//
//  AppDelegate.m
//  GT-Buses
//
//  Created by Alex Perez on 2/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "Colors.h"

@implementation AppDelegate
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    viewController = [[ViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    AboutController *aboutController = [[AboutController alloc] init];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:navController leftMenuViewController:aboutController rightMenuViewController:nil];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
        [self firstLaunch];
    return YES;
}

- (void)firstLaunch {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"selectedBusRoute"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
