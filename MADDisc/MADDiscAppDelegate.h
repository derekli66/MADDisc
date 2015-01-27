//
//  MADDiscAppDelegate.h
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimatingViewController.h"

@interface MADDiscAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) AnimatingViewController *animationViewController;

@end
