//
//  YZAnalyticsEventQueue.h
//  YZAnalytics
//
//  Created by Yeah on 16/2/14.
//  Copyright © 2016 Yeah.
//

#import <Foundation/Foundation.h>

/**
    'YZAnalyticsEventQueue' abstract operations with CoreData as a queue.
    YZAnalytics just use this to manage events object.
 */

@class YZAnalyticsEventMO;

@interface YZAnalyticsEventQueue : NSObject

/**
 *  Retrive a shared instance of YZAnalyticsEventQueue
 */
+ (YZAnalyticsEventQueue *)sharedInstance;

/**
 * Queue an event. Event will be saved imediately
 *
 * @param name    
 * @param count
 * @param parameters
 */
- (void)addEventWithName:(NSString *)name count:(NSUInteger)count parameters:(NSDictionary *)parameters;

- (void)deleteEvents:(NSArray<YZAnalyticsEventMO *> *)events;

/**
 * Get events in queue
 *
 * @return All events in  queue
 */
- (NSArray *)events;

- (void)setDeviceExt:(NSDictionary *)deviceExt;

@property (nonatomic, copy) NSString *appVersion;

@property (nonatomic, copy) NSString *userID;

@end
