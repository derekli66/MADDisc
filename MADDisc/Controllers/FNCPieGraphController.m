//
//  FNCPieGraphController.m
//  
//
//  Created by LI CHIEN-MING on 6/30/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "FNCPieGraphController.h"
#import "DDCoreDataManager.h"
#import "MADBackgroundView.h"
#import <sys/types.h>
#import <sys/sysctl.h>


static BOOL isDefaultPieChartOn = NO;

@interface FNCPieGraphController()
@property (nonatomic) CGFloat destinationAngles;//In Degree unit
@property (nonatomic) CGFloat finalDestinationAngles;//In Pi unit
@property (nonatomic, copy) NSString *finalResults;
-(NSArray*)fetchUserSelections;//回傳使用者的選擇項目
-(NSInteger)userSelectionCount;//回傳使用者選擇了多少項目
-(UIImage*)createImageFromView:(UIView* )theView;//為了將 Pie Chart View 轉換成 UIImage 再餵給 imageView
-(PieChartView*)createPieChartView;//產生 Pie Chart View
-(PieChartView*)createDefaultPieChartView;//產生預設的 PieChart 以 Furnace logo 顏色為基礎
-(NSString*)checkPlatformVersion;//檢查使用者的裝置為何？
-(CGFloat)generateDestinationAngles;//亂數產生一個終點角度為正值
-(NSArray*)generatePossibilityArray:(NSArray*)userArray;//輸入使用者所選擇項目的陣列，然後根據陣列中的每一個項目的 possibility 來計算圓餅的分配
-(NSString*)finalResultsCalculatorWithRotationClockwise:(BOOL)isClockwise;
-(void)postNotificationWhenUserDidTouchButNoSelectionYet;
-(void)showNoUserSelectionAlert;
-(void)showAlertWhenAnimationEnded;
-(void)showAlertWhenResultsIsEven;
-(void)updatePieGraphInConditionMask:(FNCPieGraphMask)theMask;
-(void)resetPieChart:(id)sender;
-(void)resetPieChartToDefaultPieChart:(id)sender;
-(void)resetDefaultPieChartToPieChart:(id)sender;
@end

@implementation FNCPieGraphController

#pragma mark - FNCPieGraphDelegate Methods
-(void)imageViewWithPieAngles:(NSArray*)arrayOfPieAngle
{
    self.currentPieArray = [NSArray arrayWithArray:arrayOfPieAngle];
    /*
    static int i = 0;
    for (NSArray *numberArray in self.currentPieArray) {
        i++;
        NSLog(@"Range No. %d is between %f and %f",i,[[numberArray objectAtIndex:0] floatValue], [[numberArray objectAtIndex:1] floatValue]);
    }
    i = 0;
     */
}

#pragma mark - FNCAnimationControllerDelegate Methods
-(void)animationDidStopInView:(UIView*)aView
{
    if (self.finalResults != nil) {
            [self performSelector:@selector(showAlertWhenAnimationEnded) withObject:nil afterDelay:0.2];
    }else{
        [self performSelector:@selector(showAlertWhenResultsIsEven) withObject:nil afterDelay:0.2];
    }

    AnimationView *animView = (AnimationView*)aView;
    [animView setDestinationAngles:[self generateDestinationAngles]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFNCRotationGameDidStop object:nil];
    
     if ([[[NSUserDefaults standardUserDefaults] objectForKey:kFNCVersionKey] isEqualToString:@"Free"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRevealADBannerView object:nil];
     };
}

-(void)animationDidStartInView:(UIView*)aView
{
    AnimationView *animView = (AnimationView*)aView;
    _finalDestinationAngles = animView.finalDestinationAngles;//final destination angles is Pi unit not degree unit. Only for clockwise or counter-clockwise check
    if (_finalDestinationAngles > 0) {
        self.finalResults = [self finalResultsCalculatorWithRotationClockwise:YES];
    }else{
        self.finalResults = [self finalResultsCalculatorWithRotationClockwise:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFNCRotationGameDidStart object:nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kFNCVersionKey] isEqualToString:@"Free"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideADBannerView object:nil];
    };
}

-(BOOL)checkUserCurrentSelection
{
    BOOL isUserCountMoreThanZero;
    if ([self userSelectionCount]>0) {
        isUserCountMoreThanZero = YES;
    }else{
        isUserCountMoreThanZero = NO;
    }
    return isUserCountMoreThanZero;
}

-(void)userDidTouchLongHand
{
    if (!([self userSelectionCount]>0)) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:kShowNoUserSelectionAlert object:nil];
        [self showNoUserSelectionAlert];
    }
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSelector:@selector(postNotificationWhenUserDidTouchButNoSelectionYet)];
    }
}

#pragma mark - Getter and Setter
-(void)setFinalResults:(NSString *)theResults
{
    if (_finalResults != theResults) {
        [_finalResults release];
        _finalResults = [theResults copy];
    }
}

#pragma mark - Custom Methods
/*產生 pie chart, 透過將 pie chart view 轉換為 UIImage 之後，在指定給 self.imageView 顯示 pie chart
 可以選擇使用背景處理或是不要背景處理
 createNewPieChartOnQueue 的使用放在 iPod Touch 4上以及 viewDidLoad裡面使用
 */
-(void)createNewPieChartOnQueue:(BOOL)queued
{
    if (queued == YES) {
        dispatch_queue_t processQueue = dispatch_queue_create("NewPieChart.Queue", NULL);
        dispatch_async(processQueue, ^{
            UIImage *aImage = [self createImageFromView:[self createPieChartView]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = aImage;
            });
        });
        dispatch_release(processQueue);
    }else{
        UIImage *aImage = [self createImageFromView:[self createPieChartView]];
        self.imageView.image = aImage;
    }
}

-(void)createDefaultPieChartOnQueue:(BOOL)queued
{
    if (queued == YES) {
        dispatch_queue_t processQueue = dispatch_queue_create("DefaultPieChart.Queue", NULL);
        dispatch_async(processQueue, ^{
            UIImage *aImage = [self createImageFromView:[self createDefaultPieChartView]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = aImage;
            });
        });
        dispatch_release(processQueue);
    }else{
        UIImage *aImage = [self createImageFromView:[self createDefaultPieChartView]];
        self.imageView.image = aImage;
    }
}

-(void)updatePieGraph{
    FNCPieGraphMask currentMask = kFNCPieGraphNoActionMask;
    //判斷使用者有無選擇任何選項
    if ([self userSelectionCount] > 0 && isDefaultPieChartOn == NO) {
        currentMask = kFNCPieGraphNormalMask;
    }else if([self userSelectionCount] == 0 && isDefaultPieChartOn == NO){
        currentMask = kFNCPieGraphToDefaultMask;
    }else if([self userSelectionCount] > 0 && isDefaultPieChartOn == YES){
        currentMask = kFNCDefaultToPieGraphMask;
    }else if([self userSelectionCount] == 0 && isDefaultPieChartOn == YES){
        currentMask = kFNCPieGraphToDefaultMask;
    }
    
    [self updatePieGraphInConditionMask:currentMask];
}

#pragma mark - Private Methods
-(void)postNotificationWhenUserDidTouchButNoSelectionYet
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoUserSelection object:nil];
}

-(void)showNoUserSelectionAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Selection Yet", @"No Selection Yet 沒有選擇項目")  //**@@**Preparing for international NSString
                                                    message:NSLocalizedString(@"Go to your Desitnies and make your selections!", @"Tell user go to Desitnies page") //**@@**Preparing for international NSString
                                                   delegate:self 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:NSLocalizedString(@"GO!", @"GO! 前往")  ,nil];//**@@**Preparing for international NSString
    [alert show];
    [alert release];
}

-(void)showAlertWhenAnimationEnded
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your Decision Is",@"Your Decision Is 您的決定是") //**@@**Preparing for international NSString 
                                                    message:self.finalResults
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK 好") //**@@**Preparing for international NSString 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)showAlertWhenResultsIsEven
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh Oh~", @"Uh Oh~ 我的天！") //**@@**Preparing for international NSString 
                                                    message:NSLocalizedString(@"It is really a hard decision! Please try again!", @"這真的是艱難的抉擇！ 請再試一次！") //**@@**Preparing for international NSString
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK",@"OK 好")//**@@**Preparing for international NSString 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(NSString*)finalResultsCalculatorWithRotationClockwise:(BOOL)isClockwise
{
    NSArray *userArray = [self fetchUserSelections];
    NSArray *degreeArray = self.currentPieArray;
    NSString *resultString = nil;

    if (isClockwise == YES) {
        for (int i = 0; i < [degreeArray count]; i++) {
            NSArray *rangeArray = [degreeArray objectAtIndex:i];
            CGFloat start = [[rangeArray objectAtIndex:0] floatValue];
            CGFloat end = [[rangeArray objectAtIndex:1] floatValue];
            if (_destinationAngles > start && _destinationAngles < end) {
                resultString = [(Decision*)[userArray objectAtIndex:i] name];
                if (resultString == nil || [resultString isEqualToString:@""]) {
                    resultString = NSLocalizedString(@"Sorry! You do not have a name for your choice!", @"抱歉！您尚未為您的機會命名！");//**@@**Preparing for international NSString
                }
            }
        }
    }else{
       CGFloat inverseDestinationAngles = 360 - self.destinationAngles;
        for (int i = 0; i < [degreeArray count]; i++) {
            NSArray *rangeArray = [degreeArray objectAtIndex:i];
            CGFloat start = [[rangeArray objectAtIndex:0] floatValue];
            CGFloat end = [[rangeArray objectAtIndex:1] floatValue];
            if (inverseDestinationAngles > start && inverseDestinationAngles < end) {
                resultString = [(Decision*)[userArray objectAtIndex:i] name];
                if (resultString == nil || [resultString isEqualToString:@""]) {
                    resultString = NSLocalizedString(@"Sorry! You do not have a name for your choice!", @"抱歉！您尚未為您的機會命名！");//**@@**Preparing for international NSString
                }
            }
        }
    }
    
    return resultString;
}

-(NSArray*)generatePossibilityArray:(NSArray*)userArray
{
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:[self userSelectionCount]];
    CGFloat value = 0;
    CGFloat sum = 0;
    for (Decision *mo in userArray) {
        sum = sum + ([mo.possibility integerValue]);
    }
    
    for (int i = 0 ; i < [self userSelectionCount]; i++) {
        Decision *item = (Decision*)[userArray objectAtIndex:i];
        value = [item.possibility integerValue];
        value = value/sum;
        [valueArray addObject:[NSNumber numberWithFloat:value]];
    }
    
    return valueArray;
}

-(CGFloat)generateDestinationAngles
{
    CGFloat theAngles = (1+arc4random()%720)/2;
    //NSLog(@"theAngles %f", theAngles);
    if (theAngles == 0 || theAngles == 360) {
        return 1;
    }
    //NSLog(@"generateDestinationAngles %f", theAngles);
    _destinationAngles = theAngles;
    return _destinationAngles;
}

-(NSArray*)fetchUserSelections
{
    return [[DDCoreDataManager coreDataManager] fetchUserSelections];
}

-(NSInteger)userSelectionCount
{
    NSArray *array = [self fetchUserSelections];
    
    NSLog(@"fetch array count: %d", [array count]);
    
    NSInteger count;
    if (array == nil) {
        count = 0;
    }else{
        count = [array count];
    }
    return count;
}

-(UIImage*)createImageFromView:(UIView* )theView
{
    if (&UIGraphicsBeginImageContextWithOptions) 
        UIGraphicsBeginImageContextWithOptions(theView.bounds.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(theView.bounds.size);
    
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

-(PieChartView*)createPieChartView
{
    NSArray *array = [self fetchUserSelections];
    NSArray *valueArray = [self generatePossibilityArray:array];
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    PieChartView *pieView = [[PieChartView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    pieView.delegate = self;
    [pieView createPieChartWithPossibilityValueArray:valueArray andUserDefaultArray:array];

    return  [pieView autorelease]; 
}

-(PieChartView*)createDefaultPieChartView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    PieChartView *pieView = [[PieChartView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    [pieView createDefaultPieChart];
    
    return [pieView autorelease];
}



//***********************************************************
//the method resetPieChart: is using GCD to create new image in background
//and also retain created image for later use
//tempImage wille be update after first animation completed.
//While the orignal code is not compatible in iPod Touch 4. Therefore, detecting device version is necessary.
//***********************************************************
-(void)resetPieChart:(id)sender
{
        
    CATransform3D preTransform = CATransform3DIdentity;//原始大小
    CATransform3D overTransform = CATransform3DScale(preTransform, 1.06, 1.06, 1.0);//over size
    __block UIImage *tempImage;//block variable
    dispatch_group_t group = dispatch_group_create();
        
        [UIView animateWithDuration:1.0 
                         animations:^{
                             dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                                 tempImage = [[self createImageFromView:[self createPieChartView]] retain];
                             });
                             //縮小 imageView
                             self.imageView.layer.transform = CATransform3DMakeScale(0.00001, 0.00001, 1.0);
                         }   
                         completion:^(BOOL finished){
                             //在此結束第一個 animation block
                             dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
                                 self.imageView.image = tempImage;
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     //開始第二個 animation block，讓圓盤 over size，然後再回到原始大小
                                     [UIView animateWithDuration:0.4 
                                                      animations:^{self.imageView.layer.transform = overTransform;} 
                                                      completion:^(BOOL finished){ 
                                                          [UIView animateWithDuration:0.3 animations:^{self.imageView.layer.transform = preTransform;}];  
                                                      }];
                                 });
                                 [tempImage release];
                             });
                         }];
    
}

-(void)resetPieChartToDefaultPieChart:(id)sender
{
    SHOW_CMD;
    CATransform3D preTransform = CATransform3DIdentity;
    CATransform3D overTransform = CATransform3DScale(preTransform, 1.06, 1.06, 1.0);//over size
    __block UIImage *tempImage;
    dispatch_group_t group = dispatch_group_create();
    
    [UIView animateWithDuration:1.0 
                     animations:^{
                         dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                           tempImage = [[self createImageFromView:[self createDefaultPieChartView]] retain];
                         });
                         self.imageView.layer.transform = CATransform3DMakeScale(0.00001, 0.00001, 1.0);        
                     } 
                     completion:^(BOOL finished){
                         dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
                             self.imageView.image = tempImage;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 //開始第二個 animation block，讓圓盤 over size，然後再回到原始大小
                                 [UIView animateWithDuration:0.4 
                                                  animations:^{self.imageView.layer.transform = overTransform; isDefaultPieChartOn = YES;} 
                                                  completion:^(BOOL finished){ 
                                                      [UIView animateWithDuration:0.3 animations:^{self.imageView.layer.transform = preTransform;}];  
                                                  }];
                             });
                             [tempImage release];
                         });
                     }];
}

-(void)resetDefaultPieChartToPieChart:(id)sender
{
    SHOW_CMD;
    CATransform3D preTransform = CATransform3DIdentity;
    CATransform3D overTransform = CATransform3DScale(preTransform, 1.06, 1.06, 1.0);//over size
    __block UIImage *tempImage;
    dispatch_group_t group = dispatch_group_create();
    
    [UIView animateWithDuration:1.0 
                     animations:^{
                         dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                              tempImage = [[self createImageFromView:[self createPieChartView]] retain];
                         });
                         self.imageView.layer.transform = CATransform3DMakeScale(0.00001, 0.00001, 1.0);        
                         isDefaultPieChartOn = NO;
                     } 
                     completion:^(BOOL finished){
                         dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
                             self.imageView.image = tempImage;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 //開始第二個 animation block，讓圓盤 over size，然後再回到原始大小
                                 [UIView animateWithDuration:0.4 
                                                  animations:^{self.imageView.layer.transform = overTransform;} 
                                                  completion:^(BOOL finished){ 
                                                      [UIView animateWithDuration:0.3 animations:^{self.imageView.layer.transform = preTransform;}];  
                                                  }];
                             });
                             [tempImage release];
                         });
                     }];
}

-(void)updatePieGraphInConditionMask:(FNCPieGraphMask)theMask
{
    switch (theMask) {
        case kFNCPieGraphNormalMask:
            //NSLog(@"kFNCPieGraphNormalMask");
            [self performSelector:@selector(resetPieChart:)];
            break;
        case kFNCPieGraphToDefaultMask:
            //NSLog(@"kFNCPieGraphToDefaultMask");
            [self performSelector:@selector(resetPieChartToDefaultPieChart:)];
            break;
        case kFNCDefaultToPieGraphMask:
            //NSLog(@"kFNCDefaultToPieGraphMask");
            [self performSelector:@selector(resetDefaultPieChartToPieChart:)];
            break;
            
        default:
            break;
    }
}

//查詢使用者目前的使用平台為何？
-(NSString*)checkPlatformVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine 
                                            encoding:NSASCIIStringEncoding];
    
    //別忘記釋放
    free(machine);
    //NSLog(@"%@", [platform substringToIndex:4]);
    return [platform substringToIndex:4];//回傳前四位英文單字(偵測是否為iPod)
}

#pragma mark - Memory Management
-(void)dealloc
{
    self.animationView = nil;
    self.imageView = nil;
    self.currentPieArray= nil;
    self.finalResults = nil;
    [super dealloc];
}

#pragma mark - Initialization
-(void)awakeFromNib
{
    CGRect screenRect = [UIScreen mainScreen].applicationFrame;
    AnimationView *theView = [[AnimationView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenRect.size.width, screenRect.size.width)];
    theView.center = CGPointMake(screenRect.size.width/2, 200.0);
    theView.backgroundColor = [UIColor clearColor];
    theView.opaque = NO;
    theView.delegate = self;
    [theView setAnimationLayerBounds:CGRectMake(0.0, 0.0, screenRect.size.width/2.5, screenRect.size.width/2 - 20.0)];
    [theView setAnimationLayerContent:(id)[UIImage imageNamed:@"LongHand001.png"].CGImage];
    [theView setDestinationAngles:[self generateDestinationAngles]];
    self.animationView = theView;
    [theView release];
    
    //放置一個 Animation View 在 self.imageView 的上方，讓Animation View 專門跑指針的動畫
    [[self.imageView superview] insertSubview:self.animationView aboveSubview:self.imageView];
    
    [self.animationView setNeedsDisplay];
    
    srandom(time(0));
}

@end
