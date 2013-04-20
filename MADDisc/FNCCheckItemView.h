//
//  FNCCheckItemView.h
//  FNCCustomTableCell
//
//  Created by LI CHIEN-MING on 7/12/11.
//  Copyright 2011 Derek. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Decision.h"
@interface FNCCheckItemView : UIView {
    FNCCellState viewStateMask;
}
@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isEditing) BOOL editing;

-(void)setViewStateMask:(FNCCellState)currentState;

@end
