//
//  TextInputViewController.h
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//


@interface TextInputViewController : UITableViewController <UITextFieldDelegate> {

}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSString *keyNameString;//a key to store name
@property (nonatomic, retain) NSString *keyOrderString;// a key to store order
@property (nonatomic, retain) NSNumber *keyOrder;//current order
@property (nonatomic, retain) NSNumber *keyPossibility;//current possibility
@property (nonatomic, retain) UIColor *keyColor;//current color

@end
