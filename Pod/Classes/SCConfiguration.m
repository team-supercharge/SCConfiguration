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
#import "RNCryptor.h"
#import "RNOpenSSLDecryptor.h"
#import "RNOpenSSLEncryptor.h"

#define LIBRARY_DIRECTORY_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Configuration2.plist"]
#define LIBRARY_ENCRYPTED_DIRECTORY_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Configuration2.enc"]

@interface SCConfiguration ()

@property (strong, nonatomic) NSString *env;
@property (strong, nonatomic) NSString *decryptionPassword;
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
#if DEBUG
        NSLog(@"INFO: ENVIRONMENT is %@", (self.env ?: @"not set"));
#endif

        _configuration = [self getConfigurationFileContent];

        NSAssert(_configuration, @"You need to create a Configuration.plist file to use SCConfiguration!");

        if (self.isOverwritePersistent)
        {
            NSDictionary *persistentConfiguration = [self getPersistentConfigurationFileContent];

            [persistentConfiguration enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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

- (void)setDecryptionPassword:(NSString *)decryptionPassword
{
    _decryptionPassword = decryptionPassword;
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
#if DEBUG
        NSLog(@"INFO: Configuration2 file saved.");
#endif

        [self writeDictionary:self.configuration toFilePath:(!_decryptionPassword ? LIBRARY_DIRECTORY_PATH : LIBRARY_ENCRYPTED_DIRECTORY_PATH)];
    }
}

#pragma mark - General method

- (id)configValueForKey:(NSString *)varName
{
    if (self.configuration[varName] == nil)
    {
#if DEBUG
        NSLog(@"INFO: '%@' key is missing from Configuration.plist", varName);
#endif
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
#if DEBUG
    NSLog(@"INFO: the '%@' key is set to protected.", varName);
#endif

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
#if DEBUG
    NSLog(@"INFO: the '%@' key is set to UNprotected.", varName);
#endif

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

- (void)setOverwriteStateToPersistent:(BOOL)state
{
    self.overwritePersistent = state;
}

- (void)overwriteConfigWithDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![self.protectedKeys containsObject:key])
        {
            if ([obj isKindOfClass:[NSNull class]])
            {
#if DEBUG
                NSLog(@"INFO: the '%@' key's value has been removed.", key);
#endif
                self.configuration[key] = nil;
            }
            else
            {
#if DEBUG
                NSLog(@"INFO: the '%@' key's value has been overwritten.", key);
#endif

                self.configuration[key] = obj;
            }
        }
        else
        {
#if DEBUG
            NSLog(@"INFO: the '%@' key's value has NOT been overwritten because it's protected!", key);
#endif
        }
    }];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    if (!key.length)
    {
        return;
    }

    if (object == nil)
    {
        object = [NSNull null];
    }

    [self overwriteConfigWithDictionary:@{key: object}];
}

#pragma mark - Private

- (NSMutableDictionary *)getConfigurationFileContent
{
    if (!_decryptionPassword)
    {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"Configuration.plist"];
        return [self loadFileFromPath:finalPath];
    }

    // the config file is encrypted
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"enc"];
    return [self loadFileFromPath:path];
}

- (NSDictionary *)getPersistentConfigurationFileContent
{
    if (!_decryptionPassword)
    {
        return [self loadFileFromPath:LIBRARY_DIRECTORY_PATH];
    }

    // the config file is encrypted
    NSDictionary *result;

    // if a non-encrypted version exists (the app used SCConfiguration before, but without encryption) replace it with an encrypted version
    if ([[NSFileManager defaultManager] fileExistsAtPath:LIBRARY_DIRECTORY_PATH])
    {
        result = [NSDictionary dictionaryWithContentsOfFile:LIBRARY_DIRECTORY_PATH];
        [self writeDictionary:result toFilePath:LIBRARY_ENCRYPTED_DIRECTORY_PATH];

        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:LIBRARY_DIRECTORY_PATH error:&error];
    }
    else
    {
        result = [self loadFileFromPath:LIBRARY_ENCRYPTED_DIRECTORY_PATH];
    }

    return result;
}

- (NSMutableDictionary *)loadFileFromPath:(NSString *)filePath
{
    NSMutableDictionary *result;

    if (!_decryptionPassword)
    {
        result = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        return result;
    }
    else // the config file is encrypted
    {
        NSData *passEncryptedData =[[NSData alloc] initWithContentsOfFile:filePath];

        NSError *error;
        NSData *dataDecrypted = [RNOpenSSLDecryptor decryptData:passEncryptedData withSettings:kRNCryptorAES256Settings password:_decryptionPassword error:&error];
        result = [NSPropertyListSerialization propertyListWithData:dataDecrypted options:NSPropertyListImmutable format:nil error:nil];
        return result;
    }
}

- (BOOL)writeDictionary:(NSMutableDictionary *)dictionary toFilePath:(NSString *)filePath
{
    if (!_decryptionPassword)
    {
        return [dictionary writeToFile:filePath atomically:YES];
    }
    else // the config file is encrypted
    {
        NSError *error;
        NSData *dataToEncrypt = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:nil error:&error];

        NSData *dataEncrypted = [RNOpenSSLEncryptor encryptData:dataToEncrypt withSettings:kRNCryptorAES256Settings password:_decryptionPassword error:&error];
        return [dataEncrypted writeToFile:filePath atomically:YES];
    }
}

@end
