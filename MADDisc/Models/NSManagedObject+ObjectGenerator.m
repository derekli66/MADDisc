//
//  NSManagedObject+ObjectGenerator.m
//  ObjectiveCPractice
//
//  Created by LEE CHIEN-MING on 1/5/15.
//  Copyright (c) 2015 Derek. All rights reserved.
//

#import "NSManagedObject+ObjectGenerator.h"

@implementation NSManagedObject (ObjectGenerator)
+ (NSManagedObject *)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)backgroundContext
{
    assert(backgroundContext != nil);
    assert(backgroundContext.concurrencyType == NSPrivateQueueConcurrencyType);
    assert(backgroundContext.parentContext != nil);
    assert(backgroundContext.parentContext.concurrencyType == NSMainQueueConcurrencyType);
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                     inManagedObjectContext:backgroundContext];
}

+ (NSManagedObject *)insertNewObjectWithProperties:(NSDictionary *)properties inManagedObjectContext:(NSManagedObjectContext *)backgroundContext
{
    NSManagedObject *result = [self insertNewObjectInManagedObjectContext:backgroundContext];
    
    if (properties) {
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (key && ![key isKindOfClass:[NSNull class]]) {
                [result setValue:obj forKey:key];
            }
        }];
    }
    
    return result;
}

- (void)saveWithCompletion:(DDContextSaveCompletion)completion
{
    NSManagedObjectContext *parentContext = self.managedObjectContext.parentContext;
    NSManagedObjectContext *topParentContext = parentContext.parentContext;
    
    assert(parentContext != nil);
    assert(parentContext.concurrencyType == NSMainQueueConcurrencyType);
    assert(topParentContext != nil);
    assert(topParentContext.concurrencyType == NSPrivateQueueConcurrencyType);
    
    __block BOOL didSave = YES;
    
    // Save in first level
    [self.managedObjectContext performBlock:^{
        __autoreleasing NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
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

@end
