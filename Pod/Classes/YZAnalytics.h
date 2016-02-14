//
//  YZAnalytics.h
//  YZAnalytics
//
//  Created by Yeah on 16/2/3.
//  Copyright © 2016 Yeah.
//

/**
 Introduction to 'YZAnalytics'
 */

#import <Foundation/Foundation.h>

@interface YZAnalytics : NSObject

/**
 *  Retrive a shared instance of YZAnalytics
 */
+ (YZAnalytics *)sharedInstance;

/**
 *  Collect any customize events you want.
 *
 * @param name                  name of event
 * @param count                  number of events that occurs this time when you collect it
 * @param parameters        additional detail infos of the event
 *
 * @discussion
 */
- (void)collectCustomEvent:(NSString *)name;
- (void)collectCustomEvent:(NSString *)name count:(NSUInteger)count;
- (void)collectCustomEvent:(NSString *)name count:(NSUInteger)count parameters:(NSDictionary *)parameters;

/**
 * Setup your api server which handles events message posted by YZAnalytics
 * 
 * @param serverURLString   server URL address as a string
 */
- (void)configureServer:(NSString *)serverURLString;

/**
 * Setup api path, don't add server url. Defafult is "events", which post data to  [serverURL]/events
 *
 * @param api   custom api path
 */
- (void)configureApiPattern:(NSString *)api;

/**
 * Setup time interval that data will be uploaded to server. Default is 300, 
 *  which upload collected events to server every 5 minutes if possible.
 *
 * @param interval      time interval
 */
- (void)configureAutoUploadInterval:(NSTimeInterval)interval;

@end
