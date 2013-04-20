//
//  AnimatingViewController.h
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BackListViewController.h"
#import "FNCPieGraphController.h"
//#import "GADBannerView.h"

@class MADBackgroundView;

@protocol BackListViewControllerProtocol;

@interface AnimatingViewController : UIViewController<BackListViewControllerProtocol, UIAlertViewDelegate> {
//    GADBannerView *_adBannerView;
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet MADBackgroundView *madDiscView;
@property (nonatomic, retain) IBOutlet UIButton *showBackListButton;

@property (nonatomic, retain) IBOutlet FNCPieGraphController *pieGraphController;

-(IBAction)showBackList:(id)sender;

@end
