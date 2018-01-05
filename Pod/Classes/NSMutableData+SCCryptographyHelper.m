//
//  NSMutableData+SCCryptographyHelper.m
//  Pods-SCConfiguration_Example
//
//  Created by Gergo Nemeth on 2017. 11. 06..
//

#import "NSMutableData+SCCryptographyHelper.h"

@implementation NSMutableData (SCCryptographyHelper)

- (NSData *)SC_consumeToIndex:(NSUInteger)index
{
    NSData *removed = [self subdataWithRange:NSMakeRange(0, index)];
    [self replaceBytesInRange:NSMakeRange(0, self.length - index) withBytes:([self mutableBytes] + index)];
    [self setLength:self.length - index];
    return removed;
}

@end
