//
//  AnimatingViewController.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 6/7/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "AnimatingViewController.h"
#import "MADBackgroundView.h"

#define SHOW_CMD NSLog(@"%@", NSStringFromSelector(_cmd))
@interface AnimatingViewController()
-(void)delayPieChartUpdate:(id)sender;
-(void)hideAndRevealShowBackListButton:(NSNotification*)notification;
@end

@implementation AnimatingViewController
@synthesize managedObjectContext = __managedObjectContext;
@synthesize navigationController = _navigationController;
@synthesize madDiscView = _madDiscView;
@synthesize showBackListButton = _showBackListButton;
@synthesize pieGraphController = _pieGraphController;

#pragma mark - BackListViewControllerProtocol Methods
-(void)backListViewControllerFinished:(id)sender{
    [self performSelector:@selector(delayPieChartUpdate:) withObject:nil afterDelay:0.3];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)delayPieChartUpdate:(id)sender{
    [self.pieGraphController performSelector:@selector(updatePieGraph)];
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{   
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    self.navigationController = nil;
    self.madDiscView = nil;
    self.pieGraphController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoUserSelection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFNCRotationGameDidStart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFNCRotationGameDidStop object:nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kFNCVersionKey] isEqualToString:@"Free"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kRevealADBannerView object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideADBannerView object:nil];
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBackList:) name:kNoUserSelection object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAndRevealShowBackListButton:) name:kFNCRotationGameDidStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAndRevealShowBackListButton:) name:kFNCRotationGameDidStop object:nil];

    [self.view addSubview:self.madDiscView];
    
    //廣告  banner 設定
//    [self createADBannerView];
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kFNCVersionKey] isEqualToString:@"Free"]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealADBannerView) name:kRevealADBannerView object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideADBannerView) name:kHideADBannerView object:nil];
//    }
}

- (void)viewDidUnload
{
    self.navigationController = nil;
    self.madDiscView = nil;
    self.pieGraphController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoUserSelection object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFNCRotationGameDidStart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFNCRotationGameDidStop object:nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kFNCVersionKey] isEqualToString:@"Free"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kRevealADBannerView object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideADBannerView object:nil];
    }

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Customized Methods
-(IBAction)showBackList:(id)sender{
    BackListViewController *aViewController = (BackListViewController*)self.navigationController.topViewController;
    aViewController.managedObjectContext = self.managedObjectContext;
    
    UIImage *image = [UIImage imageNamed:@"MADBackground.png"];
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:image];
    [self presentModalViewController:self.navigationController animated:YES];
}

-(void)hideAndRevealShowBackListButton:(NSNotification*)notification{
    if ([[notification name] isEqualToString:kFNCRotationGameDidStart]) {
        self.showBackListButton.enabled = NO;
    }
    if ([[notification name] isEqualToString:kFNCRotationGameDidStop]) {
        self.showBackListButton.enabled = YES;
    }
}
@end
