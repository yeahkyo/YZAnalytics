//
//  YZAnalyticsConnection.h
//  YZAnalytics
//
//  Created by Yeah on 16/2/14.
//  Copyright © 2016 Yeah.
//

#import <Foundation/Foundation.h>

/**
 'YZAnalyticsConnection' provides simple network functionalities to YZAnalytics to communicate
  with your analytic server.
  It's powerd by NSURLConnection, without dependencies on any 3rd party network framework.
 */
@protocol YZAnalyticsConnectionDelegate;

@interface YZAnalyticsConnection : NSObject

- (void)batchUpload:(NSArray *)events;

@property (nonatomic, copy) NSString *serverURLString;

@property (nonatomic, copy) NSString *apiPattern;

@property (nonatomic, weak) id<YZAnalyticsConnectionDelegate> delegate;

@end

#pragma mark - YZAnalyticsConnectionDelegate
@protocol YZAnalyticsConnectionDelegate <NSObject>

- (void)connection:(YZAnalyticsConnection *)connection eventsUploadSucceed:(NSArray *)events;

@end