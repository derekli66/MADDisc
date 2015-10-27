//
//  MADrawOperation.m
//  MADDisc
//
//  Created by LEE CHIEN-MING on 2/19/15.
//  Copyright (c) 2015 Furnace . All rights reserved.
//

#import "Operation.h"

@interface Operation () {
    MMOperationState _operationState;
}

@end

@implementation Operation

- (MMOperationState)operationState
{
    return _operationState;
}

- (void)setOperationState:(MMOperationState)newState
{
    @synchronized(self) {
        MMOperationState oldState;
        
        if ( (newState == MMOperationStateExecuting) || (oldState == MMOperationStateExecuting) ) {
            [self willChangeValueForKey:@"isExecuting"];
        }
        if (newState == MMOperationStateFinished) {
            [self willChangeValueForKey:@"isFinished"];
        }
        _operationState = newState;
        if (newState == MMOperationStateFinished) {
            [self didChangeValueForKey:@"isFinished"];
        }
        if ( (newState == MMOperationStateExecuting) || (oldState == MMOperationStateExecuting) ) {
            [self didChangeValueForKey:@"isExecuting"];
        }
    }
}

- (void)start
{
    self.operationState = MMOperationStateExecuting;
    
    if ([self isCancelled]) {
        [self finishedWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
    else {
        [self operationDidStart];
    }
}

// Custom Finish Method
- (void)finishedWithError:(NSError *)error
{
    [self operationWillFinish];
    self.operationState = MMOperationStateFinished;
}

#pragma mark - Subclass Override Points
- (void)operationDidStart
{
    NSAssert(![NSThread isMainThread], @"This operation should not run in main thread");
}

- (void)operationWillFinish
{
    NSAssert(![NSThread isMainThread], @"This operation should not run in main thread");
}

// Basic override properties
- (BOOL)isExecuting
{
    return (_operationState == MMOperationStateExecuting);
}

- (BOOL)isFinished
{
    return (_operationState >= MMOperationStateFinished);
}

- (void)cancel
{
    BOOL    readyToCancel;
    BOOL    oldValue;
    
    @synchronized (self) {
        oldValue = [self isCancelled];
        
        [super cancel];
        
        readyToCancel = ((!oldValue) && (self.operationState == MMOperationStateExecuting));
        
        if (readyToCancel) {
            [self finishedWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
        }
    }
}

@end
