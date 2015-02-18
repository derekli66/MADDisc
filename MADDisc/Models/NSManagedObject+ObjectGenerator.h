//
//  NSManagedObject+ObjectGenerator.h
//  ObjectiveCPractice
//
//  Created by LEE CHIEN-MING on 1/5/15.
//  Copyright (c) 2015 Derek. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObjectContextTypeDefine.h"

@interface NSManagedObject (ObjectGenerator)
+ (NSManagedObject *)insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)backgroundContext;

+ (NSManagedObject *)insertNewObjectWithProperties:(NSDictionary *)properties inManagedObjectContext:(NSManagedObjectContext *)backgroundContext;

- (void)saveWithCompletion:(DDContextSaveCompletion)completion;
@end
