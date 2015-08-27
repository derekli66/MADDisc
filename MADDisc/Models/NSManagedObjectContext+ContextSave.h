//
//  NSManagedObjectContext+ContextSave.h
//  MADDisc
//
//  Created by LEE CHIEN-MING on 2/19/15.
//  Copyright (c) 2015 Furnace . All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObjectContextTypeDefine.h"

@interface NSManagedObjectContext (ContextSave)
- (void)contextSaveAsync:(DDContextSaveCompletion)completion;
@end

@interface NSManagedObject (ObjectSave)
- (void)objectSaveAsync:(DDContextSaveCompletion)completion;
@end
