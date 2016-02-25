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

// 传输协议中定义的字段名
const static NSString *kEventNameFieldName = @"n";
const static NSString *kCountFieldName = @"c";
const static NSString *kUserIDFieldName = @"uid";
const static NSString *kAppVersionFieldName = @"apvr";
const static NSString *kTimeStampFieldName = @"t";
const static NSString *kParametersFieldName = @"p";
const static NSString *kDeviceExtensionFieldName = @"de";

const static NSString *kBatchEventCountFieldName = @"count";
const static NSString *kBatchEventsFieldName = @"events";

@interface YZAnalyticsConnection()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableArray *eventsQueue;

@end

@implementation YZAnalyticsConnection

- (void)batchUpload:(NSArray *)events {
    if (self.eventsQueue && self.eventsQueue.count > 0) {
        return;
    }
    
    self.eventsQueue = [events mutableCopy];
    
    NSMutableArray *eventArray = [NSMutableArray array];
    [events enumerateObjectsUsingBlock:^(YZAnalyticsEventMO *event, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{kEventNameFieldName: event.name,
                                                                 kCountFieldName: event.count,
                                                                 kUserIDFieldName: event.userID,
                                                                 kAppVersionFieldName: event.appVersion,
                                                                 kTimeStampFieldName: event.collectedAt
                                                                 }];
        if (event.parameters) {
            NSData  *data = [event.parameters dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *paramDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [dict setObject:paramDict forKey:kParametersFieldName];
        }
        
        if (event.deviceExt) {
            NSData *data = [event.deviceExt dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *deDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [dict setObject:deDict forKey:kDeviceExtensionFieldName];
        }
        
        [eventArray addObject:dict];
    }];
    
    NSDictionary *formattedDict = @{ kBatchEventCountFieldName: [NSNumber numberWithUnsignedLong:eventArray.count],
                                                                    kBatchEventsFieldName: eventArray
                                                                };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:formattedDict options:0 error:nil];
    NSString *logJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 对传输数据进行加密处理
    // 加密方式：
    //      STEP 1: 对 DATA_ENCRYPT_KEY 进行sha256 hash处理，获得一个可以用于AES加密的定长key（16位）；
    //      STEP 2: 使用第一步生成的16位Key对原始数据(plain)做AES-128-cbc加密处理，获得密文
    //      STEP 3: 对密文做base64编码获得可安全传输加密文本
    // 服务器端获得HTTP BODY中的密文后，需要解密得到JSON数据
    //      STEP 0: 服务器端需要获取与客户端一致的 DATA_ENCRYPT_KEY
    //      STEP 1: 对原始数据进行base64反编码
    //      STEP 2: 对 DATA_ENCRYPT_KEY进行sha256 hash处理，获得一个16位定长的Key
    //      STEP 3: 使用上一步的key对反编码后的加密文本进行AES-128-CBC解密，获得正确的JSON数据
    
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

- (void)endUploading {
    [self.delegate connection:self eventsUploadSucceed:self.eventsQueue];
    [self.eventsQueue removeAllObjects];
}

#pragma mark -- NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);

    [self endUploading];
}

#pragma mark -- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
           [self endUploading];
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}

@end
