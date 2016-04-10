//
//  SCConfiguration.m
//  Supercharge
//
//  Created by Kovacs David on 05/03/15.
//  Copyright (c) 2015 Supercharge. All rights reserved.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Supercharge <hello@supercharge.io>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SCConfiguration.h"

#define LIBRARY_DIRECTORY_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Configuration2.plist"]

@interface SCConfiguration ()

@property (strong, nonatomic) NSString *env;
@property (strong, nonatomic) NSMutableDictionary *configuration;
@property (assign, nonatomic, getter=isOverwritePersistent) BOOL overwritePersistent;

@property (strong, nonatomic) NSMutableSet *protectedKeys;

@end

@implementation SCConfiguration

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static SCConfiguration *sharedMyManager = nil;
    @synchronized(self)
    {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

#pragma mark - Lazy Instantiation

// getters
- (NSMutableDictionary *)configuration
{
    if (!_configuration)
    {
        NSLog(@"INFO: ENVIRONMENT is %@", (self.env ?: @"not set"));

        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"Configuration.plist"];
        _configuration = [NSMutableDictionary dictionaryWithContentsOfFile:finalPath];

        if (self.isOverwritePersistent)
        {
            NSDictionary *configuration2 = [NSDictionary dictionaryWithContentsOfFile:LIBRARY_DIRECTORY_PATH];

            [configuration2 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![self.protectedKeys containsObject:key])
                {
                    _configuration[key] = obj;
                }
            }];
        }
    }
    return _configuration;
}

- (NSMutableSet *)protectedKeys
{
    if (!_protectedKeys)
    {
        _protectedKeys = [NSMutableSet new];
    }
    return _protectedKeys;
}

// setters
- (void)setEnv:(NSString *)env
{
    _env = env;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.overwritePersistent = YES;
    }

    return self;
}

- (void)tearDown
{
    if (self.isOverwritePersistent)
    {
        NSLog(@"INFO: Configuration2.plist saved.");

        [self.configuration writeToFile:LIBRARY_DIRECTORY_PATH atomically:YES];
    }
}

#pragma mark - General method

- (id)configValueForKey:(NSString *)varName
{
    if (self.configuration[varName] == nil)
    {
        NSLog(@"INFO: '%@' key is missing from Configuration.plist", varName);
        return nil;
    }

    // if the key is a dictionary and it has a key with the environment
    if ([self.configuration[varName] isKindOfClass:[NSDictionary class]] && [[self.configuration[varName] allKeys] containsObject:self.env])
    {
        return self.configuration[varName][self.env];
    }

    // if the key contains the final data
    return self.configuration[varName];
}

#pragma mark - Change key protection

- (void)setKeyToProtected:(NSString *)varName
{
    NSLog(@"INFO: the '%@' key is set to protected.", varName);

    [self.protectedKeys addObject:varName];
}

- (void)setKeysToProtected:(NSArray *)varNames
{
    [varNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]])
        {
            [self setKeyToProtected:obj];
        }
    }];
}

- (void)setAllKeyToProtected
{
    [self setKeysToProtected:[self.configuration allKeys]];
}

- (void)removeKeyProtection:(NSString *)varName
{
    NSLog(@"INFO: the '%@' key is set to UNprotected.", varName);

    [self.protectedKeys removeObject:varName];
}

- (void)removeKeysFromProtection:(NSArray *)varNames
{
    [varNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]])
        {
            [self removeKeyProtection:obj];
        }
    }];
}

- (void)removeAllKeyFromProtection
{
    [self removeKeysFromProtection:[self.protectedKeys allObjects]];
}

#pragma mark - Overwite config

- (void)setOverwriteStateToPersistant:(BOOL)state
{
    self.overwritePersistent = state;
}

- (void)overwriteConfigWithDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![self.protectedKeys containsObject:key])
        {
            NSLog(@"INFO: the '%@' key's value has been overwritten.", key);

            self.configuration[key] = obj;
        }
        else
        {
            NSLog(@"INFO: the '%@' key's value has NOT been overwritten because it's protected!", key);
        }
    }];
}

@end
