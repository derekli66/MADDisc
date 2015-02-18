//
//  NSManagedObject+ObjectGenerator.m
//  ObjectiveCPractice
//
//  Created by LEE CHIEN-MING on 1/5/15.
//  Copyright (c) 2015 Derek. All rights reserved.
//

#import "NSManagedObject+ObjectGenerator.h"
#import "NSManagedObjectContext+ContextSave.h"

@implementation NSManagedObject (ObjectGenerator)
+ (NSManagedObject *)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)backgroundContext
{
    assert(backgroundContext != nil);
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
    // setup empty block if completion block is nil
    DDContextSaveCompletion handler = (completion) ? completion : ^(BOOL completed) {};
    [self.managedObjectContext contextSaveWithCompletion:handler];
}

@end
