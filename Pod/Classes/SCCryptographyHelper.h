//
//  SCCryptographyHelper.h
//  Pods-SCConfiguration_Example
//
//  Created by Gergo Nemeth on 2017. 11. 06..
//

#import <Foundation/Foundation.h>

@interface SCCryptographyHelper : NSObject

+ (NSData *)encryptData:(NSData *)dataToEncrypt withPassword:(NSString *)password;
+ (NSData *)decryptData:(NSData *)encryptedData withPassword:(NSString *)password;

@end
