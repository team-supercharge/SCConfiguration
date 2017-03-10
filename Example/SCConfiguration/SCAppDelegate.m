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
    [[SCConfiguration sharedInstance] setDecryptionPassword:@"SCConfigurationPass"];

    return YES;
}

@end
