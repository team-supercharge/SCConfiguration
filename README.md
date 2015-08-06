# SCConfiguration

Made with ♥︎ at Supercharge

## Introduction

With SCConfiguration you can easily read global or environment-dependent config data from a certain plist file.

## Installation

SCConfiguration is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "SCConfiguration"
```

## Requirements

First, you need to create a configuration file called `Configuration.plist` in your project.

You can add global or environment-dependent key-value pairs to it, here's an example with `DEBUG` and `RELEASE` environments:

```xml
<dict>
	<key>key1</key>
	<string>global value</string>
	<key>key2</key>
	<dict>
		<key>DEBUG</key>
		<string>debug value</string>
		<key>RELEASE</key>
		<string>release value</string>
	</dict>
</dict>
```

After this you can read the values with SCConfiguration class.

## Usage

First you shoud set an environment for example in the `application:didFinishLaunchingWithOptions:` method:

```objective-c
#if DEBUG
    [[SCConfiguration sharedInstance] setEnv:@"DEBUG"];
    
    // don't save modifications between application launches (set to YES by default)
    [[SCConfiguration sharedInstance] setOverwriteStateToPersistant:NO];
#else
    [[SCConfiguration sharedInstance] setEnv:@"RELEASE"];
#endif
```

You may have to add the following line to the `applicationDidEnterBackground:` and `applicationWillTerminate:` methods:

```objective-c
[[SCConfiguration sharedInstance] tearDown];
```

This methods saves modifications between application launches.

---

You can **read a value**:

```objective-c
[[SCConfiguration sharedInstance] configValueForKey:@"key1"]
```

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
