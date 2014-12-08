//
//  FNCCheckItemCell.h
//  FNCCustomTableCell
//
//  Created by LI CHIEN-MING on 7/12/11.
//  Copyright 2011 Derek. All rights reserved.
//

@class FNCCheckItemView;

@interface FNCCheckItemCell : UITableViewCell {
    
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *managedObject;

@property (nonatomic, retain) UIButton *checkedButton;
@property (nonatomic, getter = isChecked) BOOL checked;
@property (nonatomic, retain) UIImageView *buttonImageView;

-(void)redisplay;
-(void)resetCellStateMask; // 將重複使用的 cell 還原其  viewStateMask 到 kFNCCellStateDefaultMask

@end
