//
//  YZAnalyticsEventQueue.m
//  YZAnalytics
//
//  Created by Yeah on 16/2/14.
//  Copyright © 2016 Yeah.
//

#import "YZAnalyticsEventQueue.h"
#import "YZAnalyticsEventMO.h"
#import <CoreData/CoreData.h>

@interface YZAnalyticsEventQueue()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation YZAnalyticsEventQueue

+ (YZAnalyticsEventQueue *)sharedInstance {
    static YZAnalyticsEventQueue *sharedDB;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDB = [[YZAnalyticsEventQueue alloc] init];
    });
    
    return sharedDB;
}

- (void)addEventWithName:(NSString *)name count:(NSUInteger)count parameters:(NSDictionary *)parameters {
    YZAnalyticsEventMO *event =[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    event.name = name;
    event.count = count;
    
    NSString *paramsString = nil;
    if (parameters) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:event.parameters options:0 error:&error];
        if (!error) {
            paramsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    event.parameters = paramsString;
    
    [self saveContext];
}

- (NSArray *)events {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    __block NSArray *result;
    [self.managedObjectContext performBlockAndWait:^{
        result = [self.managedObjectContext executeFetchRequest:request error:nil];
    }];
    return result;
}

- (void)saveContext {
    [self.managedObjectContext performBlock:^{
        NSError *error = nil;
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Context Save Error: %@, %@", error, [error userInfo]);
        }
    }];
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle bundleForClass:[YZAnalyticsEventQueue class]] URLForResource:@"analyticslocal" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if  (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *appSuportURL = [[[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Application Support"];
        
        BOOL isDirectory;
        NSError *error = nil;
        NSURL *storeURL;
        if (![fileManager fileExistsAtPath:[appSuportURL path] isDirectory:&isDirectory] || !isDirectory) {
            [fileManager createDirectoryAtURL:appSuportURL withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!error) {
            storeURL = [appSuportURL URLByAppendingPathComponent:@"yzanalytics.sqlite"];
            
            // should be excuted asynchronized
            [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        }
        
        NSAssert(error == nil, @"Sqlite file created failed!");
    }
    
    return _persistentStoreCoordinator;
}

@end
