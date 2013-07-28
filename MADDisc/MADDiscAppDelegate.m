//
//  MADDiscAppDelegate.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "MADDiscAppDelegate.h"
#import "MADBackgroundView.h"

#define SHOW_CURRENT_METHOD NSLog(@"%@", NSStringFromSelector(_cmd))
@interface MADDiscAppDelegate()
-(NSInteger)userSelectionCount;
-(NSArray*)fetchingUserSelection;
-(CAAnimation*)furnaceLogoLayerAnimation;
-(void)delayFurnaceLogoLayerAnimation;
-(void)deleteAllObjects:(NSString *)entityDescription;
-(BOOL)isMADDiscFreeVersion;
-(BOOL)isFirstTimeStartUp;
-(void)createFirstTimeStartUpDefaultSetting;
@end

@implementation MADDiscAppDelegate
@synthesize window=_window;
@synthesize animationViewController = _animationViewController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

- (void)awakeFromNib
{   
    if ([self isFirstTimeStartUp]) {
        //在此填入預設選項
        [self createFirstTimeStartUpDefaultSetting];
    }else{
        //若是Free 版本，進行免費版本的重新設定
        if ([self isMADDiscFreeVersion]) {
            [self deleteAllObjects:@"Decision"];
            [self createFirstTimeStartUpDefaultSetting];
        }
    }
    
    AnimatingViewController *aViewController = [[AnimatingViewController alloc] initWithNibName:@"AnimatingViewController" bundle:nil];
    aViewController.view.backgroundColor = [UIColor blackColor];
    aViewController.managedObjectContext = [self managedObjectContext];
    self.animationViewController = aViewController;
    [aViewController release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window.backgroundColor = [UIColor darkGrayColor];
    [self.window setRootViewController:self.animationViewController];
    [self.window makeKeyAndVisible];
    
    //setup ManagedObjectContext in pieGraphController
    [self.animationViewController.pieGraphController setManagedObjectContext:self.managedObjectContext];
    
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

- (void)applicationWillResignActive:(UIApplication *)application
{    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{   
         //[self deleteCoreDataSqliteDatabase];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
        //[self deleteAllObjects:@"Decision"];
    //[self saveContext];


}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{  
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MADDisc" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MADDisc.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Fetched Request
-(NSArray*)fetchingUserSelection{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Decision" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"checked == %@", [NSNumber numberWithBool:YES]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    [sortDescriptors release];
    [sortDescriptor release];
    
    return array;
}
-(NSInteger)userSelectionCount{
    NSArray *array = [self fetchingUserSelection];
    NSInteger count;
    if (array == nil) {
        count = 0;
    }else{
        count = [array count];
    }
    return count;
}
#pragma mark - Startup Animation Methods
//設定 Furnace logo 的旋轉縮小動畫
-(CAAnimation*)furnaceLogoLayerAnimation{
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
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
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
-(void)delayFurnaceLogoLayerAnimation{
    [self.animationViewController.madDiscView setLogoFurnaceLayerAnimation:[self furnaceLogoLayerAnimation]];
}
#pragma mark - Delete Core Data Sqlite Database
-(void)deleteAllObjects:(NSString *)entityDescription {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [__managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in items) {
        [__managedObjectContext deleteObject:managedObject];
    }
    NSError *saveError;
    if (![__managedObjectContext save:&saveError]) {
    }
}
#pragma mark - Version Control and Start up configuration
-(BOOL)isMADDiscFreeVersion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isVersionFree = YES;

    if ([[defaults objectForKey:kFNCVersionKey] isEqualToString:@"Paid"]) {
        isVersionFree = NO;
    }
    
    //NSLog(@"isVersionFree");
    return isVersionFree;
}
-(BOOL)isFirstTimeStartUp{
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
-(void)createFirstTimeStartUpDefaultSetting{
    NSString *string = [[NSBundle mainBundle] pathForResource:@"UserSelectionDefault" ofType:@"plist"];
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:string];
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
   
    NSDictionary *startUpArray = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistData
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    
//    if ([startUpArray isKindOfClass:[NSArray class]]) {
//        NSLog(@"startUpArray is a kind of NSArray!");
//    }
//    
//    if ([startUpArray isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"startUpArray is a kind of NSDictionary");
//    }
    
    NSArray *rootArray = [startUpArray objectForKey:@"Root"];
    static int i = 1;
    
    for (NSDictionary *dic in rootArray) {
        Decision *newDecision = (Decision*)[NSEntityDescription insertNewObjectForEntityForName:@"Decision" inManagedObjectContext:self.managedObjectContext];
        UIColor *newColor = [UIColor colorWithRed:[[dic valueForKey:@"colorRed"] floatValue] 
                                            green:[[dic valueForKey:@"colorGreen"] floatValue] 
                                             blue:[[dic valueForKey:@"colorBlue"] floatValue] 
                                            alpha:1.0];
        newDecision.name = [dic objectForKey:@"name"];
        newDecision.color = newColor;
        newDecision.possibility = [dic valueForKey:@"possibility"];
        newDecision.order = [NSNumber numberWithInteger:i++];
        newDecision.checked = [dic valueForKey:@"checked"];
    }

    i = 0;
    [self saveContext];
}
@end
