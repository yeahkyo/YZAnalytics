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

@interface YZAnalyticsConnection : NSObject

- (void)uploadData:(NSArray *)events;

@property (nonatomic, copy) NSString *serverURLString;

@property (nonatomic, copy) NSString *apiPattern;

@end
