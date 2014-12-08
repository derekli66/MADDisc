//
//  AnimationView.h
//  LongHandMove
//
//  Created by LI CHIEN-MING on 7/4/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol FNCAnimationControllerDelegate <NSObject>
-(void)animationDidStopInView:(UIView*)aView;
-(void)animationDidStartInView:(UIView*)aView;
-(void)userDidTouchLongHand;
-(BOOL)checkUserCurrentSelection;
@end

@interface AnimationView : UIView {
    CFTimeInterval startTime;
    CFTimeInterval endTime;
    CATransform3D preTransform;
    
    CGPoint startPointAtContainerLayer;
    CGPoint endPointAtContainerLayer;
    
    CGPoint startPointAtSenorLayer;
    CGPoint endPointAtSensorLayer;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    CGFloat endAngles;
    
    CGFloat finalDestinationAngles;//finalDestinationAngles was decided after rotation animation triggered
}
@property (nonatomic, assign) id <FNCAnimationControllerDelegate> delegate;
@property (nonatomic) CGRect animationLayerBounds;
@property (nonatomic, readonly) CGFloat finalDestinationAngles;

-(void)setAnimationLayerContent:(id)content;
-(void)setDestinationAngles:(CGFloat)destinationAngles;//提供此方法讓 FNCPieGraphController 來設定 endAngles 為何？真正的最後位置 finalDestinationAngles 決定在使用者啟動動畫之後
@end
