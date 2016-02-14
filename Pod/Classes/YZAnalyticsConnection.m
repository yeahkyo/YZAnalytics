//
//  YZAnalyticsConnection.m
//  YZAnalytics
//
//  Created by Yeah on 16/2/14.
//  Copyright © 2016 Yeah.
//

#import "YZAnalyticsConnection.h"
#import "YZAnalyticsEventMO.h"

@interface YZAnalyticsConnection()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableArray *eventsQueue;

@end

@implementation YZAnalyticsConnection

- (void)uploadData:(NSArray<YZAnalyticsEventMO*> *)events {
    self.eventsQueue = [events mutableCopy];
    
    [self upload];
}

- (void)upload {
    YZAnalyticsEventMO *event = [self.eventsQueue firstObject];
    
    NSString *params;
    if (event.parameters) {
        params = [NSString stringWithFormat:@"n=%@&c=%lu&p=%@", event.name, (unsigned long)event.count,event.parameters];
    } else {
        params = [NSString stringWithFormat:@"n=%@&c=%lu", event.name, (unsigned long)event.count];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", self.serverURLString, self.apiPattern];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark -- NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark -- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.eventsQueue removeObjectAtIndex:0];
    
    [self upload];
}

@end
