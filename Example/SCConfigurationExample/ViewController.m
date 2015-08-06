//
//  ViewController.m
//  SCConfigurationExample
//
//  Created by Gergő Németh on 04/08/15.
//  Copyright (c) 2015 Supercharge. All rights reserved.
//

#import "ViewController.h"
#import "SCConfiguration.h"

#define GLOBAL_ENV_STRING_KEY @"GLOBAL_ENV_STRING"
#define ENV_STRING_KEY @"ENV_STRING"
#define NEW_STRING_KEY @"NEW_STRING"

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // show values
    [self showConfigValues];

    // set keys to protected
    [[SCConfiguration sharedInstance] setAllKeyToProtected];

    // try to overwrite protected keys
    NSDictionary *newConfigValues = @{
                                      GLOBAL_ENV_STRING_KEY: @"New global env value!",
                                      ENV_STRING_KEY: @"debug or release, doesn't matter..",
                                      NEW_STRING_KEY: @"New data!",
                                      };
    [[SCConfiguration sharedInstance] overwriteConfigWithDictionary:newConfigValues];

    // show values
    [self showConfigValues];

    // remove keys from protection
    [[SCConfiguration sharedInstance] removeAllKeyFromProtection];

    // overwrite unprotected keys
    [[SCConfiguration sharedInstance] overwriteConfigWithDictionary:newConfigValues];

    // show values
    [self showConfigValues];
}

#pragma mark - Private

- (void)showConfigValues {
    NSLog(@"⌄⌄⌄⌄⌄");
    NSLog(@"The '%@' key contains the following data: %@", GLOBAL_ENV_STRING_KEY, [[SCConfiguration sharedInstance] configValueForKey:GLOBAL_ENV_STRING_KEY]);
    NSLog(@"The '%@' key contains the following data: %@", ENV_STRING_KEY, [[SCConfiguration sharedInstance] configValueForKey:ENV_STRING_KEY]);
    NSLog(@"The '%@' key contains the following data: %@", NEW_STRING_KEY, [[SCConfiguration sharedInstance] configValueForKey:NEW_STRING_KEY]);
    NSLog(@"˄˄˄˄˄");
}

@end
