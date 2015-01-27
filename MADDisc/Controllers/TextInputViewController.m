//
//  TextInputViewController.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//
#import  <QuartzCore/QuartzCore.h>
#import "TextInputViewController.h"
#import "Decision.h"
#import "FNCRoundButton.h"

#define SHOW_CMD NSLog(@"%@", NSStringFromSelector(_cmd))

@interface TextInputViewController()
@property (nonatomic, retain) UITextField *decisionInputTextField;//Set up user's preference item
@property (nonatomic, retain) UISegmentedControl *possibilityControl;//Set up user's preference possibility
@property (nonatomic, retain) UIView *colorPreferenceView;//contains three slider to control user's preference color
@property (nonatomic, retain) UIView *colorView;//display user's favorite color. this color is control by slider in colorPreferenceView.
-(void)saveButtonPressed:(id)sender;
-(void)setupKeyPossibility:(id)sender;
-(void)createTextField;
-(void)createSegmentControl;
-(void)createColorPresetMatrixInView:(UIView*)theView withStartingFrame:(CGRect)theFrame;//第二版時設定 Color Matrix ，使用 UIButton 來製作不同的預設顏色選項
-(void)createColorPreferenceView;
-(void)createColorView;
-(void)colorViewChangeColor:(id)sender;
-(CGFloat)userDefaultColor:(FNCUserDefaultColorComponet)componet;//return user's default color component
@end

@implementation TextInputViewController
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObject = __managedObject;
@synthesize decisionInputTextField = _decisionInputTextField;
@synthesize keyNameString = _keyNameString;
@synthesize keyOrderString = _keyOrderString;
@synthesize keyOrder = _keyOrder;
@synthesize keyPossibility =_keyPossibility;
@synthesize keyColor = _keyColor;
@synthesize possibilityControl = _possibilityControl;
@synthesize colorPreferenceView = _colorPreferenceView;
@synthesize colorView = _colorView;
#pragma mark - Customized Method
-(void)saveButtonPressed:(id)sender{
    if (self.managedObject == nil) {
        NSManagedObjectContext *context = self.managedObjectContext;
        Decision *newDecision = [NSEntityDescription insertNewObjectForEntityForName:@"Decision" inManagedObjectContext:context];
        self.managedObject = newDecision;
        
        //Configure the managed object
        //Use KVC to set up managedObject
        [__managedObject setValue:_decisionInputTextField.text forKey:_keyNameString];//儲存使用者的選擇項目
        [__managedObject setValue:_colorView.backgroundColor forKey:@"color"];//儲存使用者的喜好顏色
        [__managedObject setValue:_keyPossibility forKey:@"possibility"];//儲存使用者的喜好機率為何？
        
        NSUInteger order = [self.keyOrder intValue];
        [__managedObject setValue:[NSNumber numberWithInt:(order+1)] forKey:_keyOrderString];//設定 新增項目的order，以利排序之用
        
    }else{
        //修改使用者已經存在的項目
        Decision *decision = (Decision*)self.managedObject;
        decision.name = _decisionInputTextField.text;
        decision.color = _colorView.backgroundColor;
        decision.possibility = _keyPossibility;
    }

        //Save the context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    
    //pop the view
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setupKeyPossibility:(id)sender{
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSInteger segmentIndex = [control selectedSegmentIndex];
    FNCPossibility userPossibility = kFNCPossibilityLow;

    switch (segmentIndex) {
        case 0: userPossibility = kFNCPossibilityLow;  break;
        case 1: userPossibility = kFNCPossibilityMedium;  break;
        case 2: userPossibility = kFNCPossibilityHigh;  break;
    }
    self.keyPossibility = [NSNumber numberWithInteger:userPossibility];
    //NSLog(@"Current pressed segment is: %d", userPossibility);
}
-(void)createTextField{
    //Create the textField
    _decisionInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(76.0, 7.0, 218.0, 36.0)];
    _decisionInputTextField.text = [self.managedObject valueForKey:@"name"];//設定 text field 的文字
    _decisionInputTextField.font = [UIFont fontWithName:@"Helvetica" size:24];
    _decisionInputTextField.clearsOnBeginEditing = NO;
    _decisionInputTextField.returnKeyType = UIReturnKeyDefault;
    _decisionInputTextField.placeholder = NSLocalizedString(@"Your Choice", @"您的機會") ; //**@@**Preparing for international NSString 
    _decisionInputTextField.delegate = self;
}
-(void)createSegmentControl{
    //Create the segment control
    NSInteger userPossibility = [[self.managedObject valueForKey:@"possibility"] integerValue];
    
    NSString *stringLow = NSLocalizedString(@"Low",@"Low 低") ; //**@@**Preparing for international NSString 
    NSString *stringMedium = NSLocalizedString(@"Medium", @"Medium 一般") ; //**@@**Preparing for international NSString
    NSString *stringHigh = NSLocalizedString(@"High", @"High 高"); //**@@**Preparing for international NSString
    NSArray *segmentArray = [NSArray arrayWithObjects:stringLow, stringMedium, stringHigh, nil];
    _possibilityControl = [[UISegmentedControl alloc] initWithItems:segmentArray];
    _possibilityControl.frame = CGRectMake(-1.0f, -1.0f, 302.0f, 46.0f);
    [_possibilityControl addTarget:self action:@selector(setupKeyPossibility:) forControlEvents:UIControlEventValueChanged];
    
    switch (userPossibility) {
        case kFNCPossibilityLow: 
            [self.possibilityControl setSelectedSegmentIndex:0];
            break;
        case kFNCPossibilityMedium: 
            [self.possibilityControl setSelectedSegmentIndex:1];
            break;
        case kFNCPossibilityHigh: 
            [self.possibilityControl setSelectedSegmentIndex:2];
            break;
            
        default:
            break;
    }
}
//第二期設定 Color Matrix
-(void)createColorPresetMatrixInView:(UIView*)theView withStartingFrame:(CGRect)theFrame{
    //第二期更新項目
    //第二版時設定 Color Matrix ，使用 UIButton 來製作不同的預設顏色選項
    CGRect firstFrame = CGRectMake(theFrame.origin.x - 29.0 , theFrame.origin.y + 48.0, 40.0, 40.0);
    
    NSArray *colorPresetArray = [self readPlistFromBundleWithFile:@"ColorPreset"];
    
    for (int i = 0; i <5; i++) {
        FNCRoundButton *firstButton = [[FNCRoundButton alloc] initWithFrame:CGRectMake(firstFrame.origin.x + (firstFrame.size.width+20)*i, firstFrame.origin.y, firstFrame.size.width, firstFrame.size.height)];
        UIColor *presetColor = [UIColor colorWithRed:[[[colorPresetArray objectAtIndex:i] valueForKey:@"ColorRed"] floatValue]
                                               green:[[[colorPresetArray objectAtIndex:i] valueForKey:@"ColorGreen"] floatValue]
                                                blue:[[[colorPresetArray objectAtIndex:i] valueForKey:@"ColorBlue"] floatValue]
                                               alpha:1.0];
        firstButton.color = presetColor;
        firstButton.showsTouchWhenHighlighted = YES;
        [firstButton addTarget:self action:@selector(colorViewChangeColor:) forControlEvents:UIControlEventTouchUpInside];
        [theView addSubview:firstButton];
        [firstButton release];
    }
    
    for (int i = 0; i <5; i++) {
        FNCRoundButton *secondButton = [[FNCRoundButton  alloc] initWithFrame:CGRectMake(firstFrame.origin.x + (firstFrame.size.width+20)*i, firstFrame.origin.y + firstFrame.size.height + 10.0, firstFrame.size.width, firstFrame.size.height)];
        UIColor *presetColor = [UIColor colorWithRed:[[[colorPresetArray objectAtIndex:i+5] valueForKey:@"ColorRed"] floatValue]
                                               green:[[[colorPresetArray objectAtIndex:i+5] valueForKey:@"ColorGreen"] floatValue]
                                                blue:[[[colorPresetArray objectAtIndex:i+5] valueForKey:@"ColorBlue"] floatValue]
                                               alpha:1.0];
        secondButton.color = presetColor;
        secondButton.showsTouchWhenHighlighted = YES;
        [secondButton addTarget:self action:@selector(colorViewChangeColor:) forControlEvents:UIControlEventTouchUpInside];
        [theView addSubview:secondButton];
        [secondButton release];
    }
}
-(void)createColorPreferenceView{
    //Create the color preference view
    if ([kFNCSoftwareVersion isEqualToString:@"101"]) {
         _colorPreferenceView = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 5.0f, 285.0f, 235.0f)];//原本的高度 128.0f，修改為 235.0f
    }else{
         _colorPreferenceView = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 5.0f, 285.0f, 128.0f)];//原本的高度 128.0f，
    }
   
    _colorPreferenceView.backgroundColor = [UIColor whiteColor];
    
    UISlider *redSlider = [[UISlider alloc] initWithFrame:CGRectMake(32.0, 6.0, 215.0, 30.0)];
    redSlider.tag = 50;
    redSlider.maximumValue = 1.0;
    redSlider.minimumValue = 0.0;
    redSlider.value = [self userDefaultColor:kFNCUserDefaultColorComponetRed];//設定 red slider 的數值
    [redSlider addTarget:self action:@selector(colorViewChangeColor:) forControlEvents:UIControlEventValueChanged];
    UIImage *imageRed = [UIImage imageNamed:@"RedPlusCircle.png"];
    UIImage *imageGray01 = [UIImage imageNamed:@"GrayMinusCircle.png"];
    UIImageView *imageViewRed = [[UIImageView alloc] initWithImage:imageRed];
    UIImageView *imageViewGray01 = [[UIImageView alloc] initWithImage:imageGray01];
    imageViewRed.frame = CGRectMake(0.0, 0.0, 29.0, 29.0); 
    imageViewRed.center = CGPointMake(redSlider.frame.size.width + redSlider.frame.origin.x + 22.0, redSlider.center.y);
    imageViewGray01.frame = CGRectMake(0.0, 0.0, 20.0, 20.0); 
    imageViewGray01.center = CGPointMake(redSlider.frame.origin.x - 18.0, redSlider.center.y);
    
    [_colorPreferenceView addSubview:redSlider];
    [_colorPreferenceView addSubview:imageViewRed];
    [_colorPreferenceView addSubview:imageViewGray01];
    
    UISlider *greenSlider = [[UISlider alloc] initWithFrame:CGRectMake(redSlider.frame.origin.x, redSlider.frame.origin.y + 43.0, redSlider.frame.size.width, redSlider.frame.size.height)];
    greenSlider.tag = 51;
    greenSlider.maximumValue = 1.0;
    greenSlider.minimumValue = 0.0;
    greenSlider.value = [self userDefaultColor:kFNCUserDefaultColorComponetGreen];//設定 green slider 的數值
    [greenSlider addTarget:self action:@selector(colorViewChangeColor:) forControlEvents:UIControlEventValueChanged];
    UIImage *imageGreen = [UIImage imageNamed:@"GreenPlusCircle.png"];
    UIImage *imageGray02 = [UIImage imageNamed:@"GrayMinusCircle.png"];
    UIImageView *imageViewGreen = [[UIImageView alloc] initWithImage:imageGreen];
    UIImageView *imageViewGray02 = [[UIImageView alloc] initWithImage:imageGray02];
    imageViewGreen.frame = CGRectMake(0.0, 0.0, 29.0, 29.0); 
    imageViewGreen.center = CGPointMake(greenSlider.frame.size.width + greenSlider.frame.origin.x + 22.0, greenSlider.center.y);
    imageViewGray02.frame = CGRectMake(0.0, 0.0, 20.0, 20.0); 
    imageViewGray02.center = CGPointMake(greenSlider.frame.origin.x - 18.0, greenSlider.center.y);
    
    [_colorPreferenceView addSubview:greenSlider];
    [_colorPreferenceView addSubview:imageViewGreen];
    [_colorPreferenceView addSubview:imageViewGray02];
    
    UISlider *blueSlider = [[UISlider alloc] initWithFrame:CGRectMake(greenSlider.frame.origin.x, greenSlider.frame.origin.y +43.0, greenSlider.frame.size.width, greenSlider.frame.size.height)];
    blueSlider.tag =52;
    blueSlider.maximumValue = 1.0;
    blueSlider.minimumValue = 0.0;
    blueSlider.value = [self userDefaultColor:kFNCUserDefaultColorComponetBlue];//設定 blue slide 的數值
    [blueSlider addTarget:self action:@selector(colorViewChangeColor:) forControlEvents:UIControlEventValueChanged];
    UIImage *imageBlue = [UIImage imageNamed:@"BluePlusCircle.png"];
    UIImage *imageGray03 = [UIImage imageNamed:@"GrayMinusCircle.png"];
    UIImageView *imageViewBlue = [[UIImageView alloc] initWithImage:imageBlue];
    UIImageView *imageViewGray03 = [[UIImageView alloc] initWithImage:imageGray03];
    imageViewBlue.frame = CGRectMake(0.0, 0.0, 29.0, 29.0); 
    imageViewBlue.center = CGPointMake(blueSlider.frame.size.width + blueSlider.frame.origin.x + 22.0, blueSlider.center.y);
    imageViewGray03.frame = CGRectMake(0.0, 0.0, 20.0, 20.0); 
    imageViewGray03.center = CGPointMake(blueSlider.frame.origin.x - 18.0, blueSlider.center.y);
    
    [_colorPreferenceView addSubview:blueSlider];
    [_colorPreferenceView addSubview:imageViewBlue];
    [_colorPreferenceView addSubview:imageViewGray03];
    
    UIView *separator01 = [[UIView alloc] initWithFrame:CGRectMake(redSlider.frame.origin.x-15.0, redSlider.frame.origin.y + 35.0, redSlider.frame.size.width+30.0, 1.0)];
    separator01.backgroundColor = [UIColor lightGrayColor];
    
    UIView *separator02 = [[UIView alloc] initWithFrame:CGRectMake(redSlider.frame.origin.x-15.0, redSlider.frame.origin.y + 80.0, redSlider.frame.size.width+30.0, 1.0)];
    separator02.backgroundColor = [UIColor lightGrayColor];
    
    [_colorPreferenceView addSubview:separator01];
    [_colorPreferenceView addSubview:separator02];
    
    //第二期更新項目
    if ([kFNCSoftwareVersion isEqualToString:@"101"]) {
        //第二期更新項目
        UIView *separator03 = [[UIView alloc] initWithFrame:CGRectMake(redSlider.frame.origin.x-15.0, redSlider.frame.origin.y + 125.0, redSlider.frame.size.width+30.0, 1.0)];
        separator03.backgroundColor = [UIColor lightGrayColor];
        //第二期更新項目
        [_colorPreferenceView addSubview:separator03];
        //第二期更新項目
        [separator03 release];
        //第二期更新項目
        [self createColorPresetMatrixInView:self.colorPreferenceView withStartingFrame:blueSlider.frame];
    }

    [redSlider release];
    [imageViewRed release];
    [imageViewGray01 release];
    [blueSlider release];
    [imageViewBlue release];
    [imageViewGray03 release];
    [greenSlider release];
    [imageViewGreen release];
    [imageViewGray02 release];
    [separator01 release];
    [separator02 release];
}
-(void)createColorView{
    //根據使用者內存的顏色設定 R G B 的參數
    CGFloat red = [self userDefaultColor:kFNCUserDefaultColorComponetRed];
    CGFloat green = [self userDefaultColor:kFNCUserDefaultColorComponetGreen];
    CGFloat blue = [self userDefaultColor:kFNCUserDefaultColorComponetBlue];
    
    _colorView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 3.0f, 50.0f, 38.0f)];
    _colorView.layer.borderWidth = 1.8f;
    _colorView.layer.cornerRadius = 8.0;
    _colorView.layer.borderColor =[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0].CGColor;
    _colorView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    _colorView.layer.masksToBounds = YES;
}
-(void)colorViewChangeColor:(id)sender{
    SHOW_CMD;
    if ([sender isKindOfClass:[UIButton class]]) {
        FNCRoundButton *actionButton = (FNCRoundButton*)sender;
        _colorView.backgroundColor = actionButton.color;
        [(UISlider*)[_colorPreferenceView viewWithTag:50] setValue:[UIColor colorComponetFromColor:actionButton.color inType:kFNCColorComponetRed]];
        [(UISlider*)[_colorPreferenceView viewWithTag:51] setValue:[UIColor colorComponetFromColor:actionButton.color inType:kFNCColorComponetGreen]];
        [(UISlider*)[_colorPreferenceView viewWithTag:52] setValue:[UIColor colorComponetFromColor:actionButton.color inType:kFNCColorComponetBlue]];
        
    }else{
        CGFloat red = [(UISlider*)[_colorPreferenceView viewWithTag:50] value];
        CGFloat green = [(UISlider*)[_colorPreferenceView viewWithTag:51] value];
        CGFloat blue = [(UISlider*)[_colorPreferenceView viewWithTag:52] value];
        _colorView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    }
}
-(CGFloat)userDefaultColor:(FNCUserDefaultColorComponet)componet{
    UIColor *userColor = [self.managedObject valueForKey:@"color"];
    if (userColor == nil) {
        userColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }
    const CGFloat *c = CGColorGetComponents(userColor.CGColor);
    switch (componet) {
        case kFNCUserDefaultColorComponetRed: return c[0]; break;
        case kFNCUserDefaultColorComponetGreen: return c[1]; break;
        case kFNCUserDefaultColorComponetBlue: return c[2]; break;
    }
    return c[0];
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
    self.managedObject = nil;
    self.managedObjectContext = nil;
    self.decisionInputTextField = nil;
    self.possibilityControl = nil;
    self.colorPreferenceView = nil;
    self.colorView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //when entering text input viewcontroller, dismiss the bottom toolbar to reveal more room to show control preference view
    [UIView animateWithDuration:0.25 animations:^{
        CGRect currentFrame = self.navigationController.toolbar.frame;
        self.navigationController.toolbar.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + 40.0, currentFrame.size.width, currentFrame.size.height);
    }];
    //check if segment control is empty, if yes, set it to lower possibility
    if (self.possibilityControl.selectedSegmentIndex == -1) {
        [self.possibilityControl setSelectedSegmentIndex:0];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect currentFrame = self.navigationController.toolbar.frame;
        self.navigationController.toolbar.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - 40.0, currentFrame.size.width, currentFrame.size.height);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Choice", @"Choice 機會") ;//**@@**Preparing for international NSString
    
    //Set up SAVE button on navigation bar
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                   target:self 
                                                                                   action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];
    
    [self createTextField];
    [self createSegmentControl];
    [self createColorPreferenceView];
    [self createColorView];
}

- (void)viewDidUnload
{
    self.managedObject = nil;
    self.managedObjectContext = nil;
    self.decisionInputTextField = nil;
    self.possibilityControl = nil;
    self.colorPreferenceView = nil;
    self.colorView = nil;
    [super viewDidUnload];
}

#pragma mark - Table View Data Source Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0: return 2; break;
        case 1: return 1; break;
    }
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        SHOW_CMD;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                UIView *cv = cell.contentView;
                [cv addSubview:_decisionInputTextField];
                [cv addSubview:_colorView];
                
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(70.0, 0.0, 1.0, cell.bounds.size.height)];
                separator.backgroundColor = [UIColor lightGrayColor];
                [cv addSubview:separator];
                [separator release];
            }else if(indexPath.row == 1){
                UIView *cv = cell.contentView;
                [cv addSubview:_colorPreferenceView];
            }
            break;
        case 1:
            if (indexPath.row == 0) {
                UIView *cv = cell.contentView;
                [cv addSubview:_possibilityControl];
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Deselect the currently selected row according to the HIG
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SHOW_CMD;
    CGFloat heightForRow;
    if (indexPath.section == 0 && indexPath.row == 1) {
        //第二期更新項目
        if ([kFNCSoftwareVersion isEqualToString:@"101"]){
            heightForRow = 245.0; //原始數值 138,
        }else{
            heightForRow = 138.0; //原始數值 138,
        }
         
    }else{
        heightForRow = 44.0;
    }

    return heightForRow;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *string = nil;
    if (section == 1) {
        string = NSLocalizedString(@"Probability", @"Probability 機率") ; //**@@**Preparing for international NSString
    }
    return string;
}
#pragma mark - Text Field Delegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_decisionInputTextField resignFirstResponder];
    return YES;
}
@end
