//
// SCConfiguration.h
// Supercharge
//
// Created by Kovacs David on 05/03/15.
// Copyright (c) 2015 Supercharge. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Supercharge <hello@supercharge.io>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <Foundation/Foundation.h>

/**
 This class can read predefined key-value pairs from a plist file called <code>Configuration.plist</code>.

 The config file may contain dictionaries with a provided key and inside every key may be a registry
 entry with the environments used in the application or the config file may contain global
 values which are not environment dependent.

 You have the ability to set certain keys protected or unprotected and you can overwite unprotected keys with a
 provided dictionary too. It's useful for example if you have a local config file but you want to overwite / add
 certain keys from an API.

 The overwrites can be set as persistant so it'll remain between application launches (this is the default behavior)
 or can be set to not persistant so the modification will be lost between application launches.
 */
@interface SCConfiguration : NSObject

#pragma mark - Singleton

///----------------
/// @name Singleton
///----------------

/**
 Returns the shared instance of the receiver class, creating it if necessary.
 
 You shoudn't override this method in your subclasses.

 @return Shared instance of the receiver class.
 */
+ (instancetype)sharedInstance;

#pragma mark - General method

///---------------------
/// @name General method
///---------------------

/**
 You can set the environment with this method for example:

 <code>[SCConfiguration setEnv:@"PRODUCTION"];</code>

 You should call this in the <code>application:didFinishLaunchingWithOptions:</code> method.

 @param env The name of the environment. For example @"DEBUG" or @"RELEASE".
 */
- (void)setEnv:(NSString *)env;

/**
 This method returns the value of the config file with the provided key and environment.

 @param varName The name of a key, the method will return the value of the key. If the key does not exists then <code>nil</code> will be returned.

 @return The value of the config file with the provided key and environment.
 */
- (id)configValueForKey:(NSString *)varName;

#pragma mark - Lifecycle

///----------------
/// @name Lifecycle
///----------------

/**
 This method saves modifications to disk so it'll remain between application launches.

 You should call this method to the <code>applicationDidEnterBackground:</code> and
 <code>applicationWillTerminate</code> methods.
 */
- (void)tearDown;

#pragma mark - Change key protection

///----------------------------
/// @name Change key protection
///----------------------------

/**
 You can set a key to protected state with this method. If you do that then it cannot be changed with the
 <code>overwriteConfigWithDictionary:</code> method.

 @param varName The name of the key which you want to set as protected. If the key doesn't exists then it will be set to protected which means you cannot add it to the configuration.
 */
- (void)setKeyToProtected:(NSString *)varName;

/**
 You can set an array of keys to protected state with this method. If you do that then it cannot be changed with the
 <code>overwriteConfigWithDictionary:</code> method.

 @param varNames An array of NSString objects. Each item is the name of a key which you want to set as protected. If the key doesn't exists then it will be set to protected which means you cannot add it to the configuration.
 */
- (void)setKeysToProtected:(NSArray *)varNames;

/**
 You can set all existing key to protected state with this method. If you do that then existing keys cannot
 be changed with the <code>overwriteConfigWithDictionary:</code> method.
 */
- (void)setAllKeyToProtected;

/**
 You can set a key to unprotected state with this method. If you do that then it can be changed with the
 <code>overwriteConfigWithDictionary:</code> method.

 @param varName The name of the key which you want to remove from protection.
 */
- (void)removeKeyProtection:(NSString *)varName;

/**
 You can set an array of keys to unprotected state with this method. If you do that then it can be changed with the
 <code>overwriteConfigWithDictionary:</code> method.

 @param varNames An array of NSString objects. Each item is the name of a key which you want to remove from protection.
 */
- (void)removeKeysFromProtection:(NSArray *)varNames;

/**
 You can set all of the protected keys's state to unprotected. If you do that then it can be changed with the
 <code>overwriteConfigWithDictionary:</code> method.
 */
- (void)removeAllKeyFromProtection;

#pragma mark - Overwite configuration file

///----------------------------------
/// @name Overwite configuration file
///----------------------------------

/**
 You can set with this method if you want to keep changes between application launches or not.

 By default this behavior is set to <code>YES</code>.

 @param state A <code>BOOL</code> value which determinates if the overwrites should remain between application launches or not.
 */
- (void)setOverwriteStateToPersistant:(BOOL)state;

/**
 You can overwrite the unprotected parts of the config dictionary with this method.
 It's useful for example if you want to change predefined config values from an API.

 @warning A key will be overwritten only if it's not set as protected before!
 @warning Overwrites will be saved between application launches by default but this functionality can be turned off with the <code>setOverwriteStateToPersistant:</code> method.

 @param dictionary An <code>NSDictionary</code> class containing key-value pairs which should be overwritten in the initial configuration file.
 */
- (void)overwriteConfigWithDictionary:(NSDictionary *)dictionary;

@end
