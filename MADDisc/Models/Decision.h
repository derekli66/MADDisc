//
//  Decision.h
//  MADDisc
//
//  Created by LI CHIEN-MING on 7/12/11.
//  Copyright (c) 2011 Derek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+ObjectGenerator.h"


@interface Decision : NSManagedObject

@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * createTime;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * possibility;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSNumber * checked;

@end
