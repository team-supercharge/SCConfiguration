//
//  NSMutableData+SCCryptographyHelper.h
//  Pods-SCConfiguration_Example
//
//  Created by Gergo Nemeth on 2017. 11. 06..
//

#import <Foundation/Foundation.h>

@interface NSMutableData (SCCryptographyHelper)

- (NSData *)SC_consumeToIndex:(NSUInteger)index;

@end
