//
//  NSString+YZEncrypt.m
//  Pods
//
//  Created by Zhang Yan on 16/2/22.
//
//

#import "NSString+YZEncrypt.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString( YZEncrypt )

- (NSData *) sha256 {
    unsigned char               *buffer;
    
    if ( ! ( buffer = (unsigned char *) malloc( CC_SHA256_DIGEST_LENGTH ) ) ) return nil;
    
    CC_SHA256( [self UTF8String], [self lengthOfBytesUsingEncoding: NSUTF8StringEncoding], buffer );
    
    return [NSData dataWithBytesNoCopy: buffer length: CC_SHA256_DIGEST_LENGTH];
}

@end