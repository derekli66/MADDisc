//
//  MADDiscAppDelegate.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "MADDiscAppDelegate.h"
#import "DDCoreDataManager.h"
#import "MADBackgroundView.h"

#define SHOW_CMD NSLog(@"%@", NSStringFromSelector(_cmd))

@implementation MADDiscAppDelegate
@synthesize window=_window;
@synthesize animationViewController = _animationViewController;

- (void)awakeFromNib
{   
    if ([self isFirstTimeStartUp]) {
        //在此填入預設選項
        [self createFirstTimeStartUpDefaultSetting];
    }
    
    AnimatingViewController *aViewController = [[AnimatingViewController alloc] initWithNibName:@"AnimatingViewController" bundle:nil];
    aViewController.view.backgroundColor = [UIColor blackColor];
    self.animationViewController = aViewController;
    [aViewController release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window.backgroundColor = [UIColor darkGrayColor];
    [self.window setRootViewController:self.animationViewController];
    [self.window makeKeyAndVisible];
    
    //hide AnimationView, imageView in pieGraphController
    //minimize AnimationView and imageView。check if user's choice items count is larger than zero, otherwise show Default Pie Chart
    //use CATransaction block shut down the implicity animation
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
    [self.animationViewController.pieGraphController.animationView setHidden:YES];
    [self.animationViewController.pieGraphController.imageView setHidden:YES];
    self.animationViewController.pieGraphController.animationView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.001, 0.001, 1.0);
    self.animationViewController.pieGraphController.imageView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.001, 0.001, 1.0);
    if ([self userSelectionCount] > 0) {
        [self.animationViewController.pieGraphController createNewPieChartOnQueue:YES];
    }else{
        [self.animationViewController.pieGraphController createDefaultPieChartOnQueue:YES];
    }
    [CATransaction commit];

    [self performSelector:@selector(delayFurnaceLogoLayerAnimation) withObject:nil afterDelay:1.0];
    
    return YES;
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

#pragma mark - Fetched Request
- (NSInteger)userSelectionCount
{
    NSArray *array = [[DDCoreDataManager coreDataManager] fetchUserSelections];
    return [array count];
}

#pragma mark - Startup Animation Methods
//設定 Furnace logo 的旋轉縮小動畫
- (CAAnimation*)furnaceLogoLayerAnimation{
    CABasicAnimation *animationRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animationRotation.toValue = [NSNumber numberWithDouble:M_PI*2];
    
    CABasicAnimation *animationScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationScale.toValue = [NSNumber numberWithFloat:0.000001];
    
    NSArray *animationArray = [NSArray arrayWithObjects: animationScale, animationRotation, nil];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.2;
    animationGroup.animations = animationArray;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.delegate = self;
    animationGroup.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    return animationGroup;
}

//當Furnace logo 旋轉動畫結束後，執行 AnimationView 以及 imageView 的放大動畫
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.0] forKey:kCATransactionAnimationDuration];
    [self.animationViewController.pieGraphController.animationView setHidden:NO];
    [self.animationViewController.pieGraphController.imageView setHidden:NO];
    [CATransaction commit];
    
    [UIView animateWithDuration:0.5 
                          delay:0.35 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         CATransform3D overTransform = CATransform3DScale(CATransform3DIdentity, 1.06, 1.06, 1.0);
                         self.animationViewController.pieGraphController.imageView.layer.transform = overTransform;
                         self.animationViewController.pieGraphController.animationView.layer.transform = CATransform3DIdentity;
                     } 
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3 
                                          animations:^{
                                              self.animationViewController.pieGraphController.imageView.layer.transform = CATransform3DIdentity;
                                              [self.animationViewController.madDiscView setLogoFurnacehide:YES];
                                              //post notification to notify animation is ended. Make showBackListButton to be enabled.
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kFNCRotationGameDidStop object:nil];
                                          }];
                     }];
}

//延遲 Furnace Logo 的旋轉縮小動畫
- (void)delayFurnaceLogoLayerAnimation{
    [self.animationViewController.madDiscView setLogoFurnaceLayerAnimation:[self furnaceLogoLayerAnimation]];
}

#pragma mark - Version Control and Start up configuration
- (BOOL)isMADDiscFreeVersion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isVersionFree = YES;

    if ([[defaults objectForKey:kFNCVersionKey] isEqualToString:@"Paid"]) {
        isVersionFree = NO;
    }
    
    //NSLog(@"isVersionFree");
    return isVersionFree;
}

- (BOOL)isFirstTimeStartUp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstTime = NO;
    
    if ([defaults objectForKey:kFNCFirstTimeStartUpKey] == nil) {
        isFirstTime = YES;
        [defaults setObject:kFNCFirstTimeStartUpKey forKey:kFNCFirstTimeStartUpKey];
        [defaults synchronize];
        
        if ([defaults objectForKey:kFNCVersionKey] == nil) {
            [defaults setObject:kFNCVersion forKey:kFNCVersionKey];
            [defaults synchronize];
        }
    }
    
    return isFirstTime;
}

- (void)createFirstTimeStartUpDefaultSetting
{
    NSString *string = [[NSBundle mainBundle] pathForResource:@"UserSelectionDefault" ofType:@"plist"];
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:string];
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
   
    NSDictionary *startUpArray = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistData
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    
    NSArray *rootArray = [startUpArray objectForKey:@"Root"];

    NSManagedObjectContext *backgroundCTX = [[DDCoreDataManager coreDataManager] createBackgroundContext];
    
    [rootArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        Decision *newDecision = (Decision *)[Decision insertNewObjectInManagedObjectContext:backgroundCTX];
        UIColor *newColor = [UIColor colorWithRed:[[dic valueForKey:@"colorRed"] floatValue]
                                            green:[[dic valueForKey:@"colorGreen"] floatValue]
                                             blue:[[dic valueForKey:@"colorBlue"] floatValue]
                                            alpha:1.0];
        
        newDecision.name = [dic objectForKey:@"name"];
        newDecision.color = newColor;
        newDecision.possibility = [dic valueForKey:@"possibility"];
        newDecision.order = [NSNumber numberWithInteger: idx + 1];
        newDecision.checked = [dic valueForKey:@"checked"];
    }];
    
    [backgroundCTX  contextSaveWithCompletion:^(BOOL completed) {
        if (completed) {
            NSLog(@"The default setting was created successful.");
        }
    }];
}
@end
