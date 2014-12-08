//
//  BackListViewController.h
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNCCheckItemCell.h"
#import "Decision.h"

@protocol BackListViewControllerProtocol <NSObject>
-(void)backListViewControllerFinished:(id)sender;
@end

@interface BackListViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
}
@property (nonatomic, assign) IBOutlet id <BackListViewControllerProtocol> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


