//
//  DDCoreDataManager.h
//  ObjectiveCPractice
//
//  Created by LEE CHIEN-MING on 1/5/15.
//  Copyright (c) 2015 Derek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+ObjectGenerator.h"
#import "NSManagedObjectContext+ContextSave.h"

static NSString *const kDDPersistentStoreSQLite = @"MADDiscData101.sqlite";
static NSString *const kDDCoreDataModel = @"MADDisc";

@interface DDCoreDataManager : NSObject
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectContext *privateSaverContext;
@property (strong, nonatomic, readonly) NSManagedObjectContext *mainThreadConext;

+ (DDCoreDataManager *)coreDataManager;

- (NSManagedObjectContext *)createBackgroundContext;

@end

@interface DDCoreDataManager (Fetch)
- (NSArray *)fetchUserSelections;
@end