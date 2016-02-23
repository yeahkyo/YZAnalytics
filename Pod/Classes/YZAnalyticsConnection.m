//
//  YZAnalyticsConnection.m
//  YZAnalytics
//
//  Created by Yeah on 16/2/14.
//  Copyright © 2016 Yeah.
//

#import "YZAnalyticsConnection.h"
#import "YZAnalyticsEventMO.h"
#import "NSData+YZEncrypt.h"
#import "NSString+YZEncrypt.h"
#import <CommonCrypto/CommonCrypto.h>

#define DATA_ENCRYPT_KEY @"78ea6310c0d800928ef64056de1381d9"

@interface YZAnalyticsConnection()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSArray *eventsQueue;

@end

@implementation YZAnalyticsConnection

- (void)batchUpload:(NSArray *)events {
    self.eventsQueue = [events copy];
    
    NSMutableArray *eventArray = [NSMutableArray array];
    [events enumerateObjectsUsingBlock:^(YZAnalyticsEventMO *event, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict;
        if (event.parameters) {
            dict = @{@"n": event.name,
                            @"c": [NSString stringWithFormat:@"%lul", (unsigned long)event.count],
                            @"p": event.parameters
                            };
        } else {
            dict = @{@"n": event.name,
                            @"c": [NSString stringWithFormat:@"%lul", (unsigned long)event.count],
                            };
        }
        
        [eventArray addObject:dict];
    }];
    
    NSDictionary *formattedDict = @{ @"count": [NSNumber numberWithUnsignedLong:eventArray.count],
                                                                    @"events": eventArray
                                                                };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:formattedDict options:0 error:nil];
    NSString *logJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *plain = [logJson dataUsingEncoding:NSUTF8StringEncoding];
    NSData *key = [NSData dataWithBytes:[[DATA_ENCRYPT_KEY sha256] bytes] length:kCCKeySizeAES128];
    NSData *encryptedData = [plain aesEncryptedDataWithKey:key];
    NSData *base64 = [[encryptedData base64Encoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", self.serverURLString, self.apiPattern];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = base64;
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark -- NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark -- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            [self.delegate connection:self eventsUploadSucceed:self.eventsQueue];
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}

@end
