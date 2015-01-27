//
//  FNCCheckItemCell.m
//  FNCCustomTableCell
//
//  Created by LI CHIEN-MING on 7/12/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "FNCCheckItemCell.h"
#import "FNCCheckItemView.h"

#define ROW_HEIGHT 50
#define SHOW_CMD NSLog(@"%@", NSStringFromSelector(_cmd))

@interface FNCCheckItemCell()
@property (nonatomic, retain) FNCCheckItemView *checkItemView;
-(void)createCheckedChangeButton;
-(void)createButtonImageView;
-(void)tapCheckButton:(id)sender;
-(void)saveCheckedItem:(BOOL)currentCheck;
-(void)hidesAndRevealImageView:(NSNotification*)notification;
-(void)delaySaving;
-(void)updateImageViewWithCheck:(BOOL)currentCheck;
-(void)uncheckedAndCheckedAll:(NSNotification*)notification;
-(NSArray*)fetchingUserSelection;
-(NSInteger)userSelectionCount;
-(void)performAlertViewWhenFull;
@end

@implementation FNCCheckItemCell
@synthesize checked = _checked;
@synthesize checkedButton = _checkedButton;
@synthesize buttonImageView = _buttonImageView;
@synthesize managedObject = __managedObject;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize checkItemView = _checkItemView;
#pragma mark - Getter and Setter
-(void)setManagedObject:(NSManagedObject *)theManagedObject{
    if (theManagedObject != __managedObject) {
        [ __managedObject release];
        __managedObject = theManagedObject;
        [__managedObject retain];
        
        [self.checkItemView  setManagedObject:__managedObject];

        self.checked = [[self.managedObject valueForKey:@"checked"] boolValue];
        
        [self updateImageViewWithCheck:[[self.managedObject valueForKey:@"checked"] boolValue]];
    }
}
#pragma mark - Custom Methods
-(void)createCheckedChangeButton{
    //Add button to control color change on imageView
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//使用 UIButtonTypeCustom 作為一個隱形的按鈕置於 cell 的 imageView 之後
    button.frame = CGRectMake(0.2, 1.0, 80.0, 48.0);
    button.alpha = 1;
    [button addTarget:self action:@selector(tapCheckButton:) forControlEvents:UIControlEventTouchUpInside];
    self.checkedButton = button;
    [self.contentView addSubview:self.checkedButton];
    [button release];
}
//在背景執行 managedObjectContext 的儲存動作
-(void)delaySaving{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self saveCheckedItem:self.checked];
    });
}
-(void)tapCheckButton:(id)sender{
    //先行確認有無達到十個最高選項 MAX_USER_SELECTION_COUNT 內定為 10
    if ([self userSelectionCount] == HUGE_VALF) {
        if (self.checked == NO) {
            [self performAlertViewWhenFull];
            return;
        }
    }

    self.checked = !self.checked;
    [self performSelector:@selector(delaySaving) withObject:nil afterDelay:0.1];
    [self updateImageViewWithCheck:self.checked];
    
    CATransform3D originalImageViewScale = self.imageView.layer.transform;
    [UIView animateWithDuration:0.09 
                     animations:^{
                         self.buttonImageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.0);
                     } 
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.06 animations:^{
                             self.buttonImageView.layer.transform = originalImageViewScale; 
                         }];
                     }];
}
-(void)saveCheckedItem:(BOOL)currentCheck{
    Decision *decision  = (Decision*)self.managedObject;
    decision.checked = [NSNumber numberWithBool:self.checked];
    [self.managedObjectContext save:nil];
}
-(void)hidesAndRevealImageView:(NSNotification*)notification{
    [UIView animateWithDuration:0.38 animations:^{  
        self.buttonImageView.alpha = (self.buttonImageView.alpha == 1) ? 0: 1;
    }];
}
-(void)updateImageViewWithCheck:(BOOL)currentCheck{
    UIImage *normalImage = [UIImage imageNamed:@"FNCUnChecked@2x.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"FNCChecked@2x.png"];
    
    if (currentCheck == YES) {
        self.buttonImageView.image = highlightImage;
    }else{
        self.buttonImageView.image = normalImage;
    }

}
-(void)redisplay{
    [self.checkItemView setNeedsDisplay];
    [self updateImageViewWithCheck:self.checked];
}
//重置 viewStateMask 到 kFNCCellStateDefaultMask, 在BackListView 中 將重複使用的 cell 還原其  viewStateMask 到 kFNCCellStateDefaultMask
-(void)resetCellStateMask{
    [self.checkItemView setViewStateMask:kFNCCellStateDefaultMask];
}
-(void)uncheckedAndCheckedAll:(NSNotification*)notification{
    if ([[notification name] isEqualToString:kCleanAllUserDefaults]) {
            self.checked = NO;
    }
    if ([[notification name] isEqualToString:kSelectAllUserDefaults]) {
            self.checked = YES;
    }

    [self updateImageViewWithCheck:self.checked]; //改變 imageView 成為紅色或是綠色，但是不儲存內部設定，交由 BackListViewController
    //There is no save action for managedObjectContext since there are invisible cell which can not be notified.
    //Saving is executed by TableViewController (BackListViewController)
}
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
    
    [sortDescriptor release];
    [sortDescriptors release];
    
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
-(void)performAlertViewWhenFull{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Selection Is Full", @"Selection Is Full 選項已經額滿")   //**@@** Localized string
                                                    message:NSLocalizedString(@"Your choices are more than 10 items. Only 10 choices you can choose.", @"最高只能選擇 10 個的提示")  //**@@** Localized string
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK 好") //**@@** Localized string 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
-(void)createButtonImageView{
#define BIV_ORIGIN_X 10
#define BIV_ORIGIN_Y 10
#define BIV_WIDTH 29
#define BIV_HEIGHT 29
    UIImage *normalImage = [UIImage imageNamed:@"FNCUnChecked@2x.png"];

    UIImageView *aImageView = [[UIImageView alloc] initWithImage:normalImage];
    aImageView.frame = CGRectMake(BIV_ORIGIN_X, BIV_ORIGIN_Y, BIV_WIDTH, BIV_HEIGHT);
    self.buttonImageView = aImageView;
    [self.contentView addSubview:self.buttonImageView];
    [aImageView release];
}
#pragma mark - Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidesAndRevealImageView:) name:kHidesAndRevealImageView object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncheckedAndCheckedAll:) name:kCleanAllUserDefaults object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncheckedAndCheckedAll:) name:kSelectAllUserDefaults object:nil];
        
        CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, ROW_HEIGHT);
		_checkItemView = [[FNCCheckItemView alloc] initWithFrame:frame];
		[self.contentView addSubview:_checkItemView];
        
        [self createCheckedChangeButton];
        [self createButtonImageView];
    }
    return self;
}
#pragma mark - UIView Methods
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.indentationLevel = 1;
    self.indentationWidth = 1;
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(
                                        indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints, 
                                        self.contentView.frame.size.height
                                        );
}
#pragma mark - UITableViewCell Methods
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
-(void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    
    if (state == UITableViewCellStateDefaultMask) {
        [self.checkItemView setViewStateMask:kFNCCellStateDefaultMask];
    }else if(state == UITableViewCellStateShowingEditControlMask){
         [self.checkItemView setViewStateMask:kFNCCellStateShowingEditControlMask];
    }else if(state == UITableViewCellStateShowingDeleteConfirmationMask){
        [self.checkItemView setViewStateMask:kFNCCellStateShowingDeleteConfirmationMask];
    }else{
        [self.checkItemView setViewStateMask:kFNCCellStateNone];
    }
}
#pragma mark - Memory Management
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHidesAndRevealImageView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCleanAllUserDefaults object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSelectAllUserDefaults object:nil];
    self.checkItemView = nil;
    self.managedObject = nil;
    self.managedObjectContext = nil;
    self.checkedButton = nil;
    [super dealloc];
}

@end
