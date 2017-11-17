//
//  SCCryptographyHelper.m
//  Pods-SCConfiguration_Example
//
//  Created by Gergo Nemeth on 2017. 11. 06..
//

#import "SCCryptographyHelper.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSMutableData+SCCryptographyHelper.h"

NSString *const kSCCryptographyHelperOpenSSLSaltedString = @"Salted__";

@implementation SCCryptographyHelper

#pragma mark - Public

+ (NSData *)encryptData:(NSData *)dataToEncrypt withPassword:(NSString *)password {
    NSData *salt = [self randomDataOfLength:8];
    NSData *calculatedIV = SCOpenSSLCryptorGetIV(password, salt);
    NSData *calculatedKey = SCOpenSSLCryptorGetKey(password, salt);
    
    NSMutableData *result = [self headerWithSalt:salt].mutableCopy;
    
    char keyPointer[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPointer, sizeof(keyPointer));  // fill with zeroes (for padding)
    [calculatedKey getBytes:keyPointer length:calculatedKey.length]; // fetch key data
    
    NSUInteger dataLength = dataToEncrypt.length;
    size_t bufferSize = (dataLength + kCCKeySizeAES256) & ~(kCCKeySizeAES256 - 1);
    char *buffer = malloc(bufferSize * sizeof(char));
    
    CCCryptorStatus ccStatus = kCCSuccess;
    size_t cryptBytes = 0; // Number of bytes moved to buffer.
    NSData *encryptionResult;
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       keyPointer,
                       kCCKeySizeAES256,
                       calculatedIV.bytes,
                       dataToEncrypt.bytes,
                       dataLength,
                       buffer,
                       bufferSize,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {
        encryptionResult = [NSData dataWithBytesNoCopy:buffer length:cryptBytes];
    }
    else {
        NSLog(@"⚠️⚠️⚠️ CCCrypt status: %d", ccStatus);
        return [NSData new];
    }
    
    [result appendData:encryptionResult];
    
    return result.copy;
}

+ (NSData *)decryptData:(NSData *)encryptedData withPassword:(NSString *)password {
    NSMutableData *encryptedMutableData = [encryptedData mutableCopy];
    
    [encryptedMutableData SC_consumeToIndex:kSCCryptographyHelperOpenSSLSaltedString.length];
    NSData *salt = [encryptedMutableData SC_consumeToIndex:8];
    NSData *calculatedKey = SCOpenSSLCryptorGetKey(password, salt);
    NSData *calculatedIV = SCOpenSSLCryptorGetIV(password, salt);
    
    CCCryptorStatus ccStatus = kCCSuccess;
    size_t cryptBytes = 0; // Number of bytes moved to buffer.
    NSMutableData *clearOut = [NSMutableData dataWithLength:encryptedMutableData.length];
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       calculatedKey.bytes,
                       kCCKeySizeAES256,
                       calculatedIV.bytes,
                       encryptedMutableData.bytes,
                       encryptedMutableData.length,
                       clearOut.mutableBytes,
                       clearOut.length,
                       &cryptBytes);
    
    if (ccStatus != kCCSuccess) {
        NSLog(@"⚠️⚠️⚠️ CCCrypt status: %d", ccStatus);
        return [NSData new];
    }
    
    clearOut.length = cryptBytes;
    return clearOut;
}

#pragma mark - Private

static NSData *SCGetHashForHash(NSData *hash, NSData *passwordSalt) {
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    
    NSMutableData *hashMaterial = [NSMutableData dataWithData:hash];
    [hashMaterial appendData:passwordSalt];
    CC_MD5([hashMaterial bytes], (CC_LONG)[hashMaterial length], md);
    
    return [NSData dataWithBytes:md length:sizeof(md)];
}

NSData *SCOpenSSLCryptorGetKey(NSString *password, NSData *salt) {
    // Hash0 = ''
    // Hash1 = MD5(Hash0 + Password + Salt)
    // Hash2 = MD5(Hash1 + Password + Salt)
    // Hash3 = MD5(Hash2 + Password + Salt)
    // Hash4 = MD5(Hash3 + Password + Salt)
    //
    // Key = Hash1 + Hash2
    // IV = Hash3 + Hash4
    
    NSMutableData *passwordSalt = [[password dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [passwordSalt appendData:salt];
    
    NSData *hash1 = SCGetHashForHash(nil, passwordSalt);
    NSData *hash2 = SCGetHashForHash(hash1, passwordSalt);
    
    NSMutableData *key = [hash1 mutableCopy];
    [key appendData:hash2];
    
    return key;
}

NSData *SCOpenSSLCryptorGetIV(NSString *password, NSData *salt) {
    NSMutableData *passwordSalt = [[password dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [passwordSalt appendData:salt];
    
    NSData *hash1 = SCGetHashForHash(nil, passwordSalt);
    NSData *hash2 = SCGetHashForHash(hash1, passwordSalt);
    NSData *hash3 = SCGetHashForHash(hash2, passwordSalt);
    NSData *hash4 = SCGetHashForHash(hash3, passwordSalt);
    
    NSMutableData *IV = [hash3 mutableCopy];
    [IV appendData:hash4];
    
    return IV;
}

+ (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    int result = SecRandomCopyBytes(NULL, length, data.mutableBytes);
    NSAssert(result == 0, @"⚠️⚠️⚠️ Unable to generate random bytes");
    
    return data;
}

+ (NSData *)headerWithSalt:(NSData *)salt {
    NSMutableData *headerData = [NSMutableData data];
    [headerData appendData:[kSCCryptographyHelperOpenSSLSaltedString dataUsingEncoding:NSUTF8StringEncoding]];
    [headerData appendData:salt];
    return headerData;
}

@end
