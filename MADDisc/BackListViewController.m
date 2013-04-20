//
//  BackListViewController.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "BackListViewController.h"
#import "TextInputViewController.h"

#define ROW_HEIGHT 50
#define SHOW_CURRENT_METHOD NSLog(@"%@", NSStringFromSelector(_cmd))

static BOOL shouldImageViewHide = NO;
static BOOL isReordering = NO;

@interface BackListViewController()
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath; 
-(void)createNewChoice:(id)sender;
-(void)toggleEdit:(id)sender;
-(NSString*)possibilityTextOnPossibility:(FNCPossibility)possibility;
-(void)delayTableViewReload;
-(void)clearAllUserDefaults:(id)sender;
-(void)selectAllUserDefaults:(id)sender;
-(void)syncUIWithCell:(UITableViewCell*)cell;
@end

@implementation BackListViewController
@synthesize delegate = _delegate;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
#pragma mark - Customized Method
//產生新的選擇項目，並且進入 TextInputViewController
-(void)createNewChoice:(id)sender{
    NSNumber *orderNumber = [NSNumber numberWithInt:[[__fetchedResultsController fetchedObjects] count]];
    
    TextInputViewController *TIVC = [[TextInputViewController alloc] initWithStyle:UITableViewStyleGrouped];
    TIVC.managedObjectContext = self.managedObjectContext;
    TIVC.keyNameString = @"name"; //設定儲存 name 的 key，作為 NSMangedObject 儲存時候的 key
    TIVC.keyOrderString = @"order"; //設定儲存 order 的 key，作為 NSMangedObject 儲存時候的 key
    TIVC.keyOrder = orderNumber;
    TIVC.view.backgroundColor = [UIColor clearColor];
    [self.navigationController pushViewController:TIVC animated:YES];
    [TIVC release];
}
-(void)toggleEdit:(id)sender{
    shouldImageViewHide = !shouldImageViewHide;
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHidesAndRevealImageView object:nil];
    
    if (self.tableView.editing == YES) {
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done 完成");//**@@**Preparing for international NSString
    }else{
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem.title =  NSLocalizedString(@"Edit", @"Edit 編輯");//**@@**Preparing for international NSString
    }
}
//回傳 possibility 所代表的字串
-(NSString*)possibilityTextOnPossibility:(FNCPossibility)possibility{
    switch (possibility) {
        case kFNCPossibilityLow:
            return @"Low";
            break;
        case kFNCPossibilityMedium:
            return @"Medium";
            break;
        case kFNCPossibilityHigh:
            return @"High";
            break;
            
        default:
            break;
    }
    return @"Undefined";
}
//當 re-ordering 結束後，重新整理 table view
-(void)delayTableViewReload{
    [self.tableView reloadData];
}
//當 table view 在 editing mode 的時候，隱藏 table view cell 上的 imageView
-(void)syncUIWithCell:(UITableViewCell*)cell{
    if (shouldImageViewHide == YES) {
        cell.imageView.alpha = 0;
    }else{
        cell.imageView.alpha = 1;
    }
}
-(void)clearAllUserDefaults:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCleanAllUserDefaults object:nil];
    //不使用背景處理方式，因為若使用者來回切換 全部清除以及全部選擇，會造成 background thread 來不及更新到 main thread
    NSArray *decisions = [[self fetchedResultsController] fetchedObjects];
    for (NSManagedObject *mo in decisions) {
        [mo setValue:[NSNumber numberWithBool:NO] forKey:@"checked"];
    }
    [self.managedObjectContext save:nil];
}
-(void)selectAllUserDefaults:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectAllUserDefaults object:nil];
    //不使用背景處理方式，因為若使用者來回切換 全部清除以及全部選擇，會造成 background thread 來不及更新到 main thread
    NSArray *decisions = [[self fetchedResultsController] fetchedObjects];
    for (NSManagedObject *mo in decisions) {
        [mo setValue:[NSNumber numberWithBool:YES] forKey:@"checked"];
    }
    [self.managedObjectContext save:nil];
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    if (&UIGraphicsBeginImageContextWithOptions) 
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    else
        UIGraphicsBeginImageContext(newSize);
    //UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - Initialization
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}
#pragma mark - Memory Management
- (void)dealloc
{
    self.delegate = nil;
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload
{
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
    self.delegate = nil;
    [super viewDidUnload];
}

#pragma mark - View lifecycle
-(void)backToDelegateView{
    if ([self.delegate respondsToSelector:@selector(backListViewControllerFinished:)]) {
        [self.delegate backListViewControllerFinished:self];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set up controller's title
    self.title = NSLocalizedString(@"Destinies", @"Destinies 命運") ; //**@@**Preparing for international NSString
    self.tableView.backgroundColor = [UIColor clearColor]; 

    //Set up UIBarButtonItem at left side
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back 回主頁")  //**@@**Preparing for international NSString
                                                               style:UIBarButtonItemStyleBordered 
                                                              target:self 
                                                              action:@selector(backToDelegateView)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    //Set up UIBarButtonItem at right side
    UIBarButtonItem *button02 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit 編輯")   //**@@**Preparing for international NSString
                                                                 style:UIBarButtonItemStyleBordered 
                                                                target:self 
                                                                action:@selector(toggleEdit:)];
    self.navigationItem.rightBarButtonItem = button02;
    [button02 release];
    
    //設定 Navigation bar 外觀
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Create tool bar button items
    UIBarButtonItem *toolBarClearButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
                                                                                       target:self 
                                                                                       action:@selector(clearAllUserDefaults:)];
    
    UIBarButtonItem *toolBarAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                      target:self 
                                                                                      action:@selector(createNewChoice:)];

    UIImage *selectAllImage = [UIImage imageNamed:@"SelectAll.png"];
    UIImage *selectAllImageResize = [self imageWithImage:selectAllImage scaledToSize:CGSizeMake(22.0, 22.0)];
    UIBarButtonItem *toolBarAllButton = [[UIBarButtonItem alloc] initWithImage:selectAllImageResize 
                                                                         style:UIBarButtonItemStylePlain 
                                                                        target:self 
                                                                        action:@selector(selectAllUserDefaults:)];
    
    UIBarButtonItem *fixedBarButton01 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //UIBarButtonItem *flexableBarButton01 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexableBarButton02 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    fixedBarButton01.width = 108.0;
    [self setToolbarItems:[NSArray arrayWithObjects:toolBarAddButton,fixedBarButton01,toolBarAllButton,flexableBarButton02,toolBarClearButton,nil] animated:YES];
    [toolBarAddButton release];
    [toolBarClearButton release];
    [toolBarAllButton release];
    [flexableBarButton02 release];
    [fixedBarButton01 release];
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {

		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = ROW_HEIGHT;
}
- (void)viewWillAppear:(BOOL)animated
{SHOW_CURRENT_METHOD;
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"section count %d", [[__fetchedResultsController sections] count]);
    return [[__fetchedResultsController sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[__fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];

}
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    // Configure the cell...
    FNCCheckItemCell *currentCell = (FNCCheckItemCell*)cell;
    Decision *aManagedDecisionObject = [__fetchedResultsController objectAtIndexPath:indexPath];
    currentCell.managedObject = aManagedDecisionObject;
    currentCell.managedObjectContext = self.managedObjectContext;
    currentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"Cell";
    
    FNCCheckItemCell *cell = (FNCCheckItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FNCCheckItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    }else{
        [cell resetCellStateMask];// 將重複使用的 cell 還原其  viewStateMask 到 kFNCCellStateDefaultMask
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    [self syncUIWithCell:cell];//同步 cell 的 UI 在 editing mode 下，避免 buttonImageView 沒有消失
    
    return cell;
}
//當手指劃過 TableViewCell 時會啟動此 delegate method
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}
//當手指啟動的 editing mode 結束後，會啟動此 delegate method
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}
//在TableViewCell 顯示之前，所呼叫的 delegate method，可以在此方法中進行最後的 TableViewCell 外觀設定
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self syncUIWithCell:cell];

    [(FNCCheckItemCell*)cell redisplay]; //字串改變後，重新整理 FNCCheckItemCell 的顯示，以同步字串的改變
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{   
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *decision = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //Coding for remove data from Model
        [self.managedObjectContext deleteObject:decision];
        [self.managedObjectContext save:nil];
        NSArray * fetchedObjects = [[self fetchedResultsController] fetchedObjects];  
        if (fetchedObjects == nil)
            return;
        
        NSMutableArray *decisions = [[[self fetchedResultsController] fetchedObjects] mutableCopy];
        
        NSUInteger i= [decisions count];
        for (NSManagedObject *mo in decisions) {
            [mo setValue:[NSNumber numberWithInt:i--] forKey:@"order"];
        }
        [decisions release]; decisions = nil;
        [self.managedObjectContext save:nil];
    }   
}
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{    
    isReordering = YES;
        NSArray * fetchedObjects = [[self fetchedResultsController] fetchedObjects];  
        if (fetchedObjects == nil)
            return;
        
        NSMutableArray *decisions = [[[self fetchedResultsController] fetchedObjects] mutableCopy];
        
        NSManagedObject *decision = [[[self fetchedResultsController] objectAtIndexPath:fromIndexPath] retain];
        
        [decisions removeObjectAtIndex:fromIndexPath.row];
        [decisions insertObject:decision atIndex:toIndexPath.row];
        [decision release];
        
        NSUInteger i= [decisions count];
        
        for (NSManagedObject *mo in decisions) {
            [mo setValue:[NSNumber numberWithInt:i--] forKey:@"order"];
        }
        [decisions release]; decisions = nil;

    [self.managedObjectContext save:nil]; 
    isReordering = NO;
    [self performSelector:@selector(delayTableViewReload) withObject:nil afterDelay:0.5];
}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Decision *decision = [__fetchedResultsController objectAtIndexPath:indexPath];
    
    TextInputViewController *TIVC = [[TextInputViewController alloc] initWithStyle:UITableViewStyleGrouped];
    TIVC.managedObjectContext = self.managedObjectContext;
    TIVC.managedObject = decision;
    TIVC.view.backgroundColor = [UIColor clearColor];
    [self.navigationController pushViewController:TIVC animated:YES];
    [TIVC release];
}
#pragma mark Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Decision" inManagedObjectContext:__managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:__managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return __fetchedResultsController;
}   

// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (isReordering) return;
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (isReordering) return;
    [self.tableView endUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (isReordering) return;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            //NSLog(@"NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            //NSLog(@"NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            //NSLog(@"NSFetchedResultsChangeUpdate");
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            NSString *sectionKeyPath = [controller sectionNameKeyPath];
            if (sectionKeyPath == nil)
                break;
            NSManagedObject *changedObject = [controller objectAtIndexPath:indexPath];
            NSArray *keyParts = [sectionKeyPath componentsSeparatedByString:@"."];
            id currentKeyValue = [changedObject valueForKeyPath:sectionKeyPath];
            for (int i = 0; i < [keyParts count] - 1; i++) {
                NSString *onePart = [keyParts objectAtIndex:i];
                changedObject = [changedObject valueForKey:onePart];
            }
            sectionKeyPath = [keyParts lastObject];
            NSDictionary *committedValues = [changedObject committedValuesForKeys:nil];
            
            if ([[committedValues valueForKeyPath:sectionKeyPath] isEqual:currentKeyValue])
                break;
            
            NSUInteger tableSectionCount = [self.tableView numberOfSections];
            NSUInteger frcSectionCount = [[controller sections] count];
            if (tableSectionCount != frcSectionCount) {
                // Need to insert a section
                NSArray *sections = controller.sections;
                NSInteger newSectionLocation = -1;
                for (id oneSection in sections) {
                    NSString *sectionName = [oneSection name];
                    if ([currentKeyValue isEqual:sectionName]) {
                        newSectionLocation = [sections indexOfObject:oneSection];
                        break;
                    }
                }
                if (newSectionLocation == -1)
                    return; // uh oh
                
                if (!((newSectionLocation == 0) && (tableSectionCount == 1) && ([self.tableView numberOfRowsInSection:0] == 0)))
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newSectionLocation] withRowAnimation:UITableViewRowAnimationFade];
                NSUInteger indices[2] = {newSectionLocation, 0};
                newIndexPath = [[[NSIndexPath alloc] initWithIndexes:indices length:2] autorelease];
            }
        }
        case NSFetchedResultsChangeMove:
            //NSLog(@"NSFetchedResultsChangeMove");
            if (!isReordering) {
                if (newIndexPath != nil) {
                    NSUInteger tableSectionCount = [self.tableView numberOfSections];
                    NSUInteger frcSectionCount = [[controller sections] count];
                    if (frcSectionCount >= tableSectionCount) 
                        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[newIndexPath section]] withRowAnimation:UITableViewRowAnimationNone];
                    else 
                        if (tableSectionCount > 1) 
                            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationNone];
                    
                    
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation: UITableViewRowAnimationRight];
                }
                else {
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }

            break;
        default:
            break;
    }
}

@end

