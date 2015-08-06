//
//  AppDelegate.m
//  SCConfigurationExample
//
//  Created by Gergő Németh on 04/08/15.
//  Copyright (c) 2015 Supercharge. All rights reserved.
//

#import "AppDelegate.h"
#import "SCConfiguration.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // set SCConfiguration environments
#if DEBUG
    [[SCConfiguration sharedInstance] setEnv:@"DEBUG"];
#else
    [[SCConfiguration sharedInstance] setEnv:@"RELEASE"];
#endif

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[SCConfiguration sharedInstance] tearDown];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.

    [[SCConfiguration sharedInstance] tearDown];
}

@end
