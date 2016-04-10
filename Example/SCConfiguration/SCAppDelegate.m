//
//  SCAppDelegate.m
//  SCConfiguration
//
//  Created by Gergő Németh on 04/10/2016.
//  Copyright (c) 2016 Gergő Németh. All rights reserved.
//

#import "SCAppDelegate.h"
#import "SCConfiguration.h"

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // set SCConfiguration environments
#if DEBUG
    [[SCConfiguration sharedInstance] setEnv:@"DEBUG"];
#else
    [[SCConfiguration sharedInstance] setEnv:@"RELEASE"];
#endif

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[SCConfiguration sharedInstance] tearDown];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    [[SCConfiguration sharedInstance] tearDown];
}

@end
