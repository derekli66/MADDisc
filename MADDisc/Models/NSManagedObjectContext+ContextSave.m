//
//  NSManagedObjectContext+ContextSave.m
//  MADDisc
//
//  Created by LEE CHIEN-MING on 2/19/15.
//  Copyright (c) 2015 Furnace . All rights reserved.
//

#import "NSManagedObjectContext+ContextSave.h"

@implementation NSManagedObjectContext (ContextSave)
- (void)contextSaveAsync:(DDContextSaveCompletion)completion
{
    NSManagedObjectContextConcurrencyType concurrentType = self.concurrencyType;
    NSManagedObjectContext *parentContext = self.parentContext;
    
    __block BOOL didSave = YES;
    
    [self performBlock:^{
        __autoreleasing NSError *error = nil;
        if (![self save:&error]) {
            NSLog(@"NSManagedObjectContext saved unsuccessfully. Current context's concurrent type is: %d. Error: %@, error code: %d", concurrentType, [error description], [error code]);
            NSAssert(error == nil, @"NSManagedObjectContext saving should not be failed.");
        }
        
        if (parentContext) {
            [parentContext contextSaveAsync:completion];
        }
        else {
            if (concurrentType != NSMainQueueConcurrencyType) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(didSave);
                });
            }
            else {
                completion(didSave);
            }
            
        }
    }];
}

@end

@implementation NSManagedObject (ObjectSave)
- (void)objectSaveAsync:(DDContextSaveCompletion)completion
{
    // setup empty block if completion block is nil
    DDContextSaveCompletion handler = (completion) ? completion : ^(BOOL completed) {};
    [self.managedObjectContext contextSaveAsync:handler];
}

@end
