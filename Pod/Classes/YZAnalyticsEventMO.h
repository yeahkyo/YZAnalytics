//
//  YZAnalyticsEventMO.h
//  tahiti
//
//  Created by Zhang Yan on 16/2/14.
//  Copyright © 2016年 OctoMusic. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface YZAnalyticsEventMO : NSManagedObject

/**
  Event name
 
  @discussion  You may use this to identify events.
 */
@property (nonatomic, copy) NSString *name;

/**
  Record how many times the event has occured

  @discussion
 */
@property (nonatomic, strong) NSNumber *count;

/**
  Additional parameters that client wants to record of the event

  @discussion  the parameters will always be json like format.
                           It's YZAnalytics' responsibility to translate information into json string.
 */
@property (nonatomic, copy) NSString *parameters;

/**
    Version of app in which event occured.
 */
@property (nonatomic, copy) NSString *appVersion;

/**
    The user who is logged in when the event occured.
 */
@property (nonatomic, copy) NSString *userID;

/**
    
 */
@property (nonatomic, copy) NSString *collectedAt;

@property (nonatomic, copy) NSString  *deviceExt;

@end
