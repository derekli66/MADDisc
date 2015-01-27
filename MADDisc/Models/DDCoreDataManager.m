//
//  DDCoreDataManager.m
//  ObjectiveCPractice
//
//  Created by LEE CHIEN-MING on 1/5/15.
//  Copyright (c) 2015 Derek. All rights reserved.
//

#import "DDCoreDataManager.h"
#import "NSManagedObjectContext-EasyFetch.h"

@interface DDCoreDataManager ()
@property (strong, nonatomic, readwrite) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *privateSaverContext;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *mainThreadConext;
@end

@implementation DDCoreDataManager
#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        // init all properties
        [self managedObjectModel];
        [self persistentStoreCoordinator];
        [self privateSaverContext];
        [self mainThreadConext];
    }
    return self;
}

+ (DDCoreDataManager *)coreDataManager
{
    static DDCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (NSString *)persistentStoreFilePath
{
    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [homePath stringByAppendingPathComponent:kDDPersistentStoreSQLite];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDDCoreDataModel withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath:[self persistentStoreFilePath]];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption : @YES
                             };
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    __autoreleasing NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        NSLog(@"CoreData : Unresolved error,\n error code: %d,\n error info: %@\n", (int)[error code], [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)privateSaverContext
{
    if (_privateSaverContext) {
        return _privateSaverContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator) {
        _privateSaverContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateSaverContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _privateSaverContext;
}

- (NSManagedObjectContext *)mainThreadConext
{
    if (_mainThreadConext) {
        return _mainThreadConext;
    }
    
    NSManagedObjectContext *privateContext = [self privateSaverContext];
    
    if (privateContext) {
        _mainThreadConext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainThreadConext.parentContext = privateContext;
    }
    
    return _mainThreadConext;
}

- (NSManagedObjectContext *)createBackgroundContext
{
    NSManagedObjectContext *mainCTX = [self mainThreadConext];    
    assert(mainCTX != nil);
    NSManagedObjectContext *backgroundCTX = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundCTX.parentContext = mainCTX;
    return [backgroundCTX autorelease];
}

- (void)saveBackgroundContext:(NSManagedObjectContext *)backgroundContext completion:(DDContextSaveCompletion)completion
{
    NSManagedObjectContext *parentContext = backgroundContext.parentContext;
    NSManagedObjectContext *topParentContext = parentContext.parentContext;
    
    assert(parentContext != nil);
    assert(parentContext.concurrencyType == NSMainQueueConcurrencyType);
    assert(topParentContext != nil);
    assert(topParentContext.concurrencyType == NSPrivateQueueConcurrencyType);
    
    __block BOOL didSave = YES;
    
    // Save in first level
    [backgroundContext performBlock:^{
        __autoreleasing NSError *error = nil;
        if (![backgroundContext save:&error]) {
            didSave = NO;
            NSLog(@"Core Data save failed at first level. Error code: %d, error info: %@", (int)[error code], [error description]);
        }
        
        // Save in second level
        [parentContext performBlock:^{
            __autoreleasing NSError *error2 = nil;
            if (didSave) {
                if (![parentContext save:&error2]) {
                    if (completion) completion(NO);
                    NSLog(@"Core Data save in main thred is not successful. Error: %@", [error2 description]);
                }
                else {
                    if (completion) completion(YES);
                }
                
                // Save in final level
                [topParentContext performBlock:^{
                    __autoreleasing NSError *bigError = nil;
                    if (![topParentContext save:&bigError]) {
                        NSAssert(!bigError, [bigError description]);
                    }
                }]; // final level block
            }
            else {
                if (completion) completion(NO);
            }
            
        }]; // second level block
        
    }];// first level block
}

- (void)dealloc
{
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_privateSaverContext release];
    [_mainThreadConext release];
    [super dealloc];
}

@end

@implementation DDCoreDataManager (Fetch)

- (NSArray *)fetchUserSelections
{
    NSArray *array = [self.mainThreadConext fetchObjectsForEntityName:@"Decision" sortByKey:@"order" ascending:NO predicateWithFormat:@"checked == %@", @YES];
    return array;
}

@end
