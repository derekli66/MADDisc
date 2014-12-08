//
//  FNCPieGraphController.h
//  
//
//  Created by LI CHIEN-MING on 6/30/11.
//  Copyright 2011 Derek. All rights reserved.
//***********************************************************
//FNCPieGraphController 同時為 PieChartView 以及 AnimationView 的 delegate
//FNCPieGraphController 利用 IBOutlet 連結 UIImageView 作為存放 PieChartView 所產生的圖檔
//在執行檔中會將 PieChartView 進行轉換，以增加程式效率，因為在 PieChartView 當中，利用 CALayer 的shadow 來產生陰影
//此陰影會降低 iOS 的顯示效能，因此採用轉換圖檔的方式
//AnimationView 利用 programming 的方式置於 UIImageView 之上專職動畫之用
//***********************************************************

#import <QuartzCore/QuartzCore.h>
#import "PieChartView.h"
#import "AnimationView.h"
#import "Decision.h"

@interface FNCPieGraphController : NSObject <FNCPieGraphDelegate, FNCAnimationControllerDelegate>
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;//imageView 是為了裝載 Pie Graph Image(UIImage object) 
@property (nonatomic, retain) AnimationView *animationView;//animationView 置於 imageView 之上
@property (nonatomic, retain) NSArray *currentPieArray;//To store angles for each pie

-(void)createNewPieChartOnQueue:(BOOL)queued;
-(void)createDefaultPieChartOnQueue:(BOOL)queued;
-(void)updatePieGraph;
@end
