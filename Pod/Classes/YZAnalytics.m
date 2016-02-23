//
//  YZAnalytics.m
//  YZAnalytics
//
//  Created by Yeah on 16/2/3.
//  Copyright © 2016 Yeah.
//

#import "YZAnalytics.h"

#import "YZAnalyticsEventQueue.h"
#import "YZAnalyticsConnection.h"

#pragma mark - Directives 

#define DEFAULT_AUTO_UPLOAD_INTERVAL    5
#define DEFAULT_API                                              @"events"

#pragma mark - YZAnalytics
@interface YZAnalytics()<YZAnalyticsConnectionDelegate>

@property (nonatomic, strong) YZAnalyticsConnection *connection;
@property (nonatomic, strong) YZAnalyticsEventQueue *eventQueue;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation YZAnalytics

+ (YZAnalytics *)sharedInstance {
    static YZAnalytics *sharedAnlytics;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAnlytics = [[YZAnalytics alloc] init];
    });
    
    return sharedAnlytics;
}

- (instancetype)init {
    if (self = [super init]) {
        [self startWithTimeInterval:DEFAULT_AUTO_UPLOAD_INTERVAL];
    }
    
    return self;
}

- (void)configureServer:(NSString *)serverURLString {
    self.connection.serverURLString = serverURLString;
}

- (void)configureApiPattern:(NSString *)api {
    self.connection.apiPattern = api;
}

- (void)configureAutoUploadInterval:(NSTimeInterval)interval {
    [self startWithTimeInterval:interval];
}

- (void)startWithTimeInterval:(NSTimeInterval)timeInterval {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                  target:self
                                                selector:@selector(onTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)collectCustomEvent:(NSString *)name {
    [self collectCustomEvent:name count:1 parameters:nil];
}

- (void)collectCustomEvent:(NSString *)name count:(NSUInteger)count {
    [self collectCustomEvent:name count:count parameters:nil];
}

- (void)collectCustomEvent:(NSString *)name count:(NSUInteger)count parameters:(NSDictionary *)parameters {
    [self.eventQueue addEventWithName:name count:count parameters:parameters];
}

- (void)onTimer {
    NSArray *storedEvents = [self.eventQueue events];
    if (storedEvents.count > 0) {
        [self.connection batchUpload:[self.eventQueue events]];
    }
}

#pragma mark -- YZAnalyticsConnectionDelegate
- (void)connection:(YZAnalyticsConnection *)connection eventsUploadSucceed:(NSArray *)events {
    [self.eventQueue deleteEvents:events];
}

#pragma mark -- lazy load
- (YZAnalyticsEventQueue *)eventQueue {
    if (!_eventQueue) {
        _eventQueue = [YZAnalyticsEventQueue sharedInstance];
    }
    
    return _eventQueue;
}

- (YZAnalyticsConnection *)connection {
    if (!_connection) {
        _connection = [[YZAnalyticsConnection alloc] init];
        _connection.apiPattern = DEFAULT_API;
        _connection.delegate = self;
    }
    
    return _connection;
}

@end
