# SCConfiguration

[![CI Status](http://img.shields.io/travis/team-supercharge/SCConfiguration.svg?style=flat)](https://travis-ci.org/team-supercharge/SCConfiguration)
[![Version](https://img.shields.io/cocoapods/v/SCConfiguration.svg?style=flat)](http://cocoadocs.org/docsets/SCConfiguration)
[![License](https://img.shields.io/cocoapods/l/SCConfiguration.svg?style=flat)](http://cocoadocs.org/docsets/SCConfiguration)
[![Platform](https://img.shields.io/cocoapods/p/SCConfiguration.svg?style=flat)](http://cocoadocs.org/docsets/SCConfiguration)

Made with ♥︎ at Supercharge

## Introduction

With SCConfiguration you can easily manage environment dependent (or global) configuration parameters in a property list file.

## Installation

SCConfiguration is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "SCConfiguration"
```

## Usage

### Defining the parameters in the Configuration.plist file

First, you need to create a configuration file called `Configuration.plist` in your project.

![Configuration.plist](plist.png)

You can add global or environment dependent key-value pairs to it, here's an example with `STAGING` and `PRODUCTION` environments.

In source format:

```xml
<dict>
	<key>APPLE_APP_ID</key> <!-- global parameter -->
	<string>123456789</string>
	<key>API_URL</key>  <!-- environment dependent parameter -->
	<dict>
		<key>STAGING</key>
		<string>https://staging.myappserver.com</string>
		<key>PRODUCTION</key>
		<string>https://myappserver.com</string>
	</dict>
</dict>
```

### Setting the environment and reading the parameters

If `ENV` is a preprocessor macro defined by the build configuration you can easily set the configuration class's environment in the `application:didFinishLaunchingWithOptions:` method:

```objective-c
SCConfiguration *configuration = [SCConfiguration new];

// Set the environment defined by the ENV preprocessor macro
[configuration setEnv:ENV];

// Read the API_URL environment dependent value from the configuration
NSString *apiUrl = [configuration configValueForKey:@"API_URL"]
```

You can also use `SCConfiguration` as a singleton:

```objective-c
// Set the environment defined by the ENV preprocessor macro
[[SCConfiguration sharedInstance] setEnv:ENV];

// Read the API_URL environment dependent value from the configuration
NSString *apiUrl = [[SCConfiguration sharedInstance] configValueForKey:@"API_URL"]
```

## Subclassing SCConfiguration

It's a good practice to subclass `SCConfiguration` and declare your configuration parameters explicitly in your application.

```
// MyAppConfiguration.h

@interface MyAppConfiguration : SCConfiguration

- (NSString *)apiUrl;

@end
```

```
// MyAppConfiguration.m

@interface MyAppConfiguration : SCConfiguration

- (NSString *)apiUrl
{
    return (NSString *)[self configValueForKey:@"API_URL"];
}

@end
```

## Overriding configuartion variables

You can override configuration variable at runtime. This can be useful if you would like to synchronize configuration parameters through a backend service.

You need to add the following line to the `applicationDidEnterBackground:` and `applicationWillTerminate:` methods:

```objective-c
[[SCConfiguration sharedInstance] tearDown];
```

This method saves the configuration modifications between application launches.

You can **overwrite / add key-value pairs**:

```objective-c
NSDictionary *newConfigValues = @{ @"key1": @"new value", @"new key": @"new value" };
[[SCConfiguration sharedInstance] overwriteConfigWithDictionary:newConfigValues];
```

**NOTE: overwritten key-value pairs will stay between application launches by default! You can change this behaivor by calling the `[[SCConfiguration sharedInstance] setOverwriteStateToPersistant:NO]`.**

Or you can **set key-value pairs to protected / unprotected**:

```objective-c
[[SCConfiguration sharedInstance] setKeysToProtected:@[@"key2", @"key3"]];
[[SCConfiguration sharedInstance] setKeyToProtected:@"key4"];

[[SCConfiguration sharedInstance] removeAllKeyFromProtection];
```

**Protected values cannot be changed / added later.**

## Compatibility

iOS 6+

## Contributing

Contributions are always welcome! (:

1. Fork it ( http://github.com/team-supercharge/SCConfiguration/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

SCConfiguration is available under the MIT license. See the LICENSE file for more info.
