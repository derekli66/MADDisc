//
//  MADrawOperation.h
//  MADDisc
//
//  Created by LEE CHIEN-MING on 2/19/15.
//  Copyright (c) 2015 Furnace . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MMOperationState) {
    MMOperationStateInit = 0,
    MMOperationStateExecuting = 1,
    MMOperationStateFinished = 2,
};

@interface MMOperation : NSOperation
@property (nonatomic, readonly) MMOperationState operationState;

- (void)operationDidStart;

- (void)operationWillFinish;

- (void)finishedWithError:(NSError *)error;
@end
