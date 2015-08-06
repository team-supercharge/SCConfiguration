//
//  SCConfigurationExampleTests.m
//  SCConfigurationExampleTests
//
//  Created by Gergő Németh on 04/08/15.
//  Copyright (c) 2015 Supercharge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SCConfiguration.h"

#define GLOBAL_ENV_STRING_KEY @"GLOBAL_ENV_STRING"
#define ENV_STRING_KEY @"ENV_STRING"
#define NEW_STRING_KEY @"NEW_STRING"

#define NEW_VALUE @"new value"

#define LIBRARY_DIRECTORY_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Configuration2.plist"]

@interface SCConfigurationTests : XCTestCase

@end

@implementation SCConfigurationTests

#pragma mark - Setup and Teardown methods

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Test singleton

- (void)testSharedInstance
{
    id config = [SCConfiguration sharedInstance];
    XCTAssertNotNil(config, @"sharedInstance method shouldn't return nil");

    if (![config isKindOfClass:[SCConfiguration class]])
    {
        XCTFail(@"sharedInstance method should return a SCConfiguration instance");
    }
}

#pragma mark - Test different environments

- (void)testDebugEnv
{
    NSString *configString;
    NSString *expectedResult;

    SCConfiguration *config = [[SCConfiguration alloc] init];
    [config setEnv:@"DEBUG"];
    [config setOverwriteStateToPersistant:NO];

    // test if the right result comes or not
    configString = [config configValueForKey:GLOBAL_ENV_STRING_KEY];
    expectedResult = @"global env value";
    XCTAssertTrue([configString isEqualToString:expectedResult], @"Strings are not equal '%@' != '%@' for key: '%@'", configString, expectedResult, GLOBAL_ENV_STRING_KEY);

    configString = [config configValueForKey:ENV_STRING_KEY];
    expectedResult = @"debug..";
    XCTAssertTrue([configString isEqualToString:expectedResult], @"Strings are not equal '%@' != '%@' for key: '%@'", configString, expectedResult, ENV_STRING_KEY);

    // not existing
    configString = [config configValueForKey:NEW_STRING_KEY];
    expectedResult = nil;
    XCTAssertNil(expectedResult, @"String is '%@' but the expected result would be nil for the key: '%@'", configString, NEW_STRING_KEY);
}

- (void)testReleaseEnv
{
    NSString *configString;
    NSString *expectedResult;

    SCConfiguration *config = [[SCConfiguration alloc] init];
    [config setEnv:@"RELEASE"];
    [config setOverwriteStateToPersistant:NO];

    // test if the right result comes or not
    configString = [config configValueForKey:GLOBAL_ENV_STRING_KEY];
    expectedResult = @"global env value";
    XCTAssertTrue([configString isEqualToString:expectedResult], @"Strings are not equal '%@' != '%@' for key: '%@'", configString, expectedResult, GLOBAL_ENV_STRING_KEY);

    configString = [config configValueForKey:ENV_STRING_KEY];
    expectedResult = @"release!";
    XCTAssertTrue([configString isEqualToString:expectedResult], @"Strings are not equal '%@' != '%@' for key: '%@'", configString, expectedResult, ENV_STRING_KEY);

    // not existing
    configString = [config configValueForKey:NEW_STRING_KEY];
    expectedResult = nil;
    XCTAssertNil(expectedResult, @"String is '%@' but the expected result would be nil for the key: '%@'", configString, NEW_STRING_KEY);
}

#pragma mark - Test save to file functionality

- (void)testTearDown
{
    SCConfiguration *config = [[SCConfiguration alloc] init];
    [config setEnv:@"DEBUG"];
    [config setOverwriteStateToPersistant:YES];
    [config tearDown];

    // after tearDown method a Configuration2.plist file should be exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:LIBRARY_DIRECTORY_PATH];
    if (!fileExists)
    {
        XCTFail(@"Configuration2.plist file should be exists!");
    }
}

#pragma mark - Test key protection

- (void)testKeyProtection
{
    NSString *configString;

    SCConfiguration *config = [[SCConfiguration alloc] init];
    [config setEnv:@"DEBUG"];
    [config setOverwriteStateToPersistant:NO];

    [config setAllKeyToProtected];
    [config setKeyToProtected:NEW_STRING_KEY];

    NSDictionary *newConfigValues = @{
                                      GLOBAL_ENV_STRING_KEY: NEW_VALUE,
                                      ENV_STRING_KEY: NEW_VALUE,
                                      NEW_STRING_KEY: NEW_VALUE,
                                      };
    [config overwriteConfigWithDictionary:newConfigValues];

    // test if the right result comes or not
    configString = [config configValueForKey:GLOBAL_ENV_STRING_KEY];
    XCTAssertFalse([configString isEqualToString:NEW_VALUE], @"Strings shouldn't be equal '%@' != '%@' for key: '%@'", configString, NEW_VALUE, GLOBAL_ENV_STRING_KEY);

    configString = [config configValueForKey:ENV_STRING_KEY];
    XCTAssertFalse([configString isEqualToString:NEW_VALUE], @"Strings shouldn't be equal '%@' != '%@' for key: '%@'", configString, NEW_VALUE, ENV_STRING_KEY);

    configString = [config configValueForKey:NEW_STRING_KEY];
    XCTAssertNil(configString, @"Result should be nil for key: '%@'", NEW_STRING_KEY);

    [config removeAllKeyFromProtection];

    [config overwriteConfigWithDictionary:newConfigValues];

    // test if the right result comes or not
    configString = [config configValueForKey:GLOBAL_ENV_STRING_KEY];
    XCTAssertTrue([configString isEqualToString:NEW_VALUE], @"Strings should be equal '%@' != '%@' for key: '%@'", configString, NEW_VALUE, GLOBAL_ENV_STRING_KEY);

    configString = [config configValueForKey:ENV_STRING_KEY];
    XCTAssertTrue([configString isEqualToString:NEW_VALUE], @"Strings should be equal '%@' != '%@' for key: '%@'", configString, NEW_VALUE, ENV_STRING_KEY);

    configString = [config configValueForKey:NEW_STRING_KEY];
    XCTAssertTrue([configString isEqualToString:NEW_VALUE], @"Strings should be equal '%@' != '%@' for key: '%@'", configString, NEW_VALUE, NEW_STRING_KEY);
}

@end
