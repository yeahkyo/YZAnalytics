//
//  NSData+YZEncrypt.h
//  Pods
//
//  Created by Zhang Yan on 16/2/22.
//
//

#import <Foundation/Foundation.h>

@interface NSData (YZEncrypt)

- (NSData *) aesEncryptedDataWithKey:(NSData *) key;
- (NSString *) base64Encoding;

@end
