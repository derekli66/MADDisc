//
//  AnimationView.m
//  LongHandMove
//
//  Created by LI CHIEN-MING on 7/4/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "AnimationView.h"
#import "FNCCALayerDrawingDelegate.h"
#import "FNCPieGraphController.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)
#define SHOW_CURRENT_METHOD NSLog(@"%@",NSStringFromSelector(_cmd))

static BOOL isSensorLayerAdded = NO;

@interface AnimationView()
@property (nonatomic, retain) CALayer *longHandLayer;
@property (nonatomic, retain) CALayer *touchSensorLayer;
@property (nonatomic, retain) FNCCALayerDrawingDelegate *drawingDelegate;
-(void)rotationAnimationWithLayer:(CALayer*)animatingLayer inRightSideDirection:(BOOL)isRightSide;
-(void)backToOriginalState;
-(void)addTouchSensorLayer;
-(void)removeTouchSensorLayer;
-(void)resetTimeAndPoint;
-(void)showCheatingAlert;
-(FNCRotationType)userRotationConditionWithStartPoint:(CGPoint)firstPoint andEndPoint:(CGPoint)lastPoint;
@end

@implementation AnimationView
@synthesize drawingDelegate = _drawingDelegate;
@synthesize finalDestinationAngles = _finalDestinationAngles;
@synthesize delegate = _delegate;
@synthesize animationLayerBounds;
@synthesize longHandLayer = _longHandLayer;
@synthesize touchSensorLayer = _touchSensorLayer;
#pragma mark - Custom Method
-(void)setAnimationLayerBounds:(CGRect)layerBounds{
    CALayer *containerLayer = [_longHandLayer superlayer];
    
    containerLayer.bounds = layerBounds;
    containerLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    _longHandLayer.bounds = CGRectMake(layerBounds.origin.x, layerBounds.origin.y, layerBounds.size.width/3.5, layerBounds.size.height + (layerBounds.size.width/3.5)/2);
    _longHandLayer.position = CGPointMake(layerBounds.size.width/2, layerBounds.size.height/2 + _longHandLayer.bounds.size.width/4);
    [self.longHandLayer setNeedsDisplay];
    //NSLog(@"_longHandLayer.bounds.size.width %f", _longHandLayer.bounds.size.width);
    //NSLog(@"_longHandLayer.bounds.size.height %f", _longHandLayer.bounds.size.height);
    
    _touchSensorLayer.bounds = CGRectMake(layerBounds.origin.x, layerBounds.origin.y, self.bounds.size.width, self.bounds.size.width);
    _touchSensorLayer.position = CGPointMake(layerBounds.size.width/2, layerBounds.size.height/2);
    
    preTransform = containerLayer.transform;//事先求取 containerLayer 的原始變形值
}
-(void)setAnimationLayerContent:(id)content{
    _longHandLayer.contents = content;
}
-(void)setDestinationAngles:(CGFloat)destinationAngles{
    //destinationAngles 使用 角度
    //endAngles 使用 徑度( Pi )
    endAngles = degreesToRadians(destinationAngles + 360*14);
}
-(void)addTouchSensorLayer{
    isSensorLayerAdded = YES;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.longHandLayer.superlayer addSublayer:self.touchSensorLayer];
    [CATransaction commit];
}
-(void)removeTouchSensorLayer{
    isSensorLayerAdded = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.touchSensorLayer removeFromSuperlayer];
    [CATransaction commit];
}
-(void)resetTimeAndPoint{
    startTime = 0.0;
    endTime = 0.0;
    startPointAtSenorLayer = CGPointZero;
    endPointAtSensorLayer = CGPointZero;
    startPointAtContainerLayer = CGPointZero;
    endPointAtContainerLayer = CGPointZero;
    startPoint = CGPointZero;
    endPoint = CGPointZero;
}
-(FNCRotationType)userRotationConditionWithStartPoint:(CGPoint)firstPoint andEndPoint:(CGPoint)lastPoint{
    FNCRotationType condition;
    
    if (lastPoint.y < self.center.y) {
        if ((lastPoint.x - firstPoint.x) > 0) {
            condition = kFNCClockwiseRotation;
        }else{
            condition = kFNCCounterClockwiseRotation;
        }
    }else{
        if ((lastPoint.x - firstPoint.x) < 0) {
            condition = kFNCClockwiseRotation;
        }else{
            condition = kFNCCounterClockwiseRotation;
        }
    }
    
    return condition;
}
#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if (self) {
        //設定一個 containLayer 裝載 _longHandLalyer, 原因是要擴大 _longHandLayer 的觸控範圍
        CALayer *containerLayer = [CALayer layer];
        containerLayer.bounds = CGRectZero;
        containerLayer.anchorPoint = CGPointMake(0.5, 1.0); //設定 anchorPoint 在containerLayer 的下方
        containerLayer.backgroundColor = [UIColor clearColor].CGColor;//設定透明背景
        
        _drawingDelegate = [[FNCCALayerDrawingDelegate alloc] init];
        
        _longHandLayer = [[CALayer layer] retain];
        _longHandLayer.bounds = CGRectZero;
        //_longHandLayer.delegate = _drawingDelegate; //不使用 delegate，保留此 delegate 設定，當設定delegate後可以讓 long hand layer 畫出指針

        [containerLayer addSublayer:_longHandLayer];//將 _longHandLayer 裝入 containerLayer 當中

        _touchSensorLayer = [[CALayer layer] retain];
        _touchSensorLayer.bounds = CGRectZero;
        _touchSensorLayer.backgroundColor = [UIColor clearColor].CGColor;

        [self.layer addSublayer:containerLayer];
        
        self.backgroundColor = [UIColor clearColor];//設定自身背景為透明背景
        self.opaque = NO;//設定不透明度為 NO，考量圖像內容以及所包含的 Layer 包含 Alpha值
        
        isSensorLayerAdded = NO;
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //設定一個 containLayer 裝載 _longHandLalyer, 原因是要擴大 _longHandLayer 的觸控範圍
        CALayer *containerLayer = [CALayer layer];
        containerLayer.bounds = CGRectZero;
        containerLayer.anchorPoint = CGPointMake(0.5, 1.0); //設定 anchorPoint 在containerLayer 的下方
        containerLayer.backgroundColor = [UIColor clearColor].CGColor;//設定透明背景
        
        _drawingDelegate = [[FNCCALayerDrawingDelegate alloc] init];
        
        _longHandLayer = [[CALayer layer] retain];
        _longHandLayer.bounds = CGRectZero;
        //_longHandLayer.delegate = _drawingDelegate; //不使用 delegate，保留此 delegate 設定，當設定delegate後可以讓 long hand layer 畫出指針

        [containerLayer addSublayer:_longHandLayer];//將 _longHandLayer 裝入 containerLayer 當中
        
        _touchSensorLayer = [[CALayer layer] retain];
        _touchSensorLayer.bounds = CGRectZero;
        _touchSensorLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        [self.layer addSublayer:containerLayer];
        
        self.backgroundColor = [UIColor clearColor];//設定自身背景為透明背景
        self.opaque = NO;//設定不透明度為 NO，考量圖像內容以及所包含的 Layer 包含 Alpha值
        
        isSensorLayerAdded = NO;
    }
    return self;
}

#pragma mark - Memory Management
- (void)dealloc
{
    self.delegate = nil;
    self.longHandLayer = nil;
    self.touchSensorLayer = nil;
    self.drawingDelegate = nil;
    [super dealloc];
}

#pragma mark - Animation Control Methods
//根據選轉方向設定順時針或是逆時針旋轉動畫
-(void)rotationAnimationWithLayer:(CALayer*)animatingLayer inRightSideDirection:(BOOL)isRightSide{
    _finalDestinationAngles = isRightSide? endAngles:endAngles*(-1);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 5.0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.toValue = [NSNumber numberWithDouble: _finalDestinationAngles];
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.05 :0.4 :0.25 :0.98];
    animation.delegate = self;
    [animatingLayer addAnimation:animation forKey:@"transform.rotation.z"];
    
    self.userInteractionEnabled = NO;
}
//將指針恢復到原始位置以及移除先前的 animation 物件
-(void)backToOriginalState{
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithDouble:1.0] forKey:kCATransactionAnimationDuration];
    [self.longHandLayer.superlayer removeAnimationForKey:@"transform.rotation.z"];
    self.longHandLayer.superlayer.transform = preTransform;
    [CATransaction commit];
    
    self.userInteractionEnabled = YES;
}
// CAAnimation Delegate Method
-(void)animationDidStart:(CAAnimation *)anim{
    [self.delegate animationDidStartInView:self];
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.delegate animationDidStopInView:self];
    [self performSelector:@selector(backToOriginalState) withObject:nil afterDelay:1.5];
    [self resetTimeAndPoint];
    [self removeTouchSensorLayer];
}
//當手指移動時，讓指針跟著手指旋轉
-(void)rotateLongHandLayerWithPoint:(CGPoint)currentPoint{
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithDouble:0.0] forKey:kCATransactionAnimationDuration];
    CGFloat rot = atan2(-(_longHandLayer.superlayer.position.x - currentPoint.x), _longHandLayer.superlayer.position.y - currentPoint.y);
    self.longHandLayer.superlayer.transform = CATransform3DMakeRotation(rot, 0.0, 0.0, 1.0);
    [CATransaction commit];
}
//show up a cheating alert to user
-(void)showCheatingAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Stop Cheating", @"Tell user not cheat")  //**@@**Preparing for international NSString
                                                    message:NSLocalizedString(@"Please swipe the long hand with fast speed!",@"Tell user how to trigger long hand rotation")  //**@@**Preparing for international NSString
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"Got It",@"Confirm with Got It")  //**@@**Preparing for international NSString
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
//*******************************************************
//當手指觸碰指針範圍時，新增一個 touch sensor layer 在 container layer 上
//container layer 的用途為增加手指的感應範圍，以增加指針動畫的靈敏度
//所偵測的點若包含在 sensor layer 當中，即記錄當下時間，以作為觸發旋轉動畫的判斷
//同時記錄手指在 View 上的開始以及最後位置，作為順時針以及逆時針旋轉的判斷依據
//*******************************************************
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint currentPoint = [[touches anyObject] locationInView:self];

    startPointAtContainerLayer = [self.layer convertPoint:currentPoint toLayer:self.longHandLayer.superlayer];
    if ([self.longHandLayer.superlayer containsPoint:startPointAtContainerLayer]) {
        [self rotateLongHandLayerWithPoint:currentPoint];
        if ([self.delegate checkUserCurrentSelection] == YES) {
            //若使用者有輸入選項，增加 sensor layer
            if (!isSensorLayerAdded){ 
                [self addTouchSensorLayer];
            }
        }else{
            [self.delegate userDidTouchLongHand];//回傳告訴 delegate 使用者已經接觸 long hand，讓delegate 進行其他動作
            [self backToOriginalState];//long hand 回到原點，因為沒有使用者輸入
        }
    }
    
    startPointAtSenorLayer = [self.layer convertPoint:currentPoint toLayer:self.touchSensorLayer];
    if ([self.touchSensorLayer containsPoint:startPointAtSenorLayer]) {
        startTime = CACurrentMediaTime();
    }
    
    startPoint = currentPoint;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    
    startPointAtContainerLayer = [self.layer convertPoint:currentPoint toLayer:self.longHandLayer.superlayer];
    if ([self.longHandLayer.superlayer containsPoint:startPointAtContainerLayer]) {
        [self rotateLongHandLayerWithPoint:currentPoint];
        if ([self.delegate checkUserCurrentSelection] == YES) {
            //若使用者有輸入選項，增加 sensor layer
            if (!isSensorLayerAdded) {
                [self addTouchSensorLayer];
            }
        }else{
            [self.delegate userDidTouchLongHand];//回傳告訴 delegate 使用者已經接觸 long hand，讓delegate 進行其他動作
            [self backToOriginalState];//long hand 回到原點，因為沒有使用者輸入
        }
    }
    
    startPointAtSenorLayer = [self.layer convertPoint:currentPoint toLayer:self.touchSensorLayer];
    if ([self.touchSensorLayer containsPoint:startPointAtSenorLayer]) {
        startTime = CACurrentMediaTime();
    }
    
    startPoint = currentPoint;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    
    endPointAtContainerLayer = [self.layer convertPoint:currentPoint toLayer:self.longHandLayer.superlayer];
    if ([self.longHandLayer.superlayer containsPoint:endPointAtContainerLayer]) {
        [self rotateLongHandLayerWithPoint:currentPoint];
    }
    
    endPointAtSensorLayer = [self.layer convertPoint:currentPoint toLayer:self.touchSensorLayer];
    if ([self.touchSensorLayer containsPoint:endPointAtSensorLayer]) {
            endTime = CACurrentMediaTime();
    }

    endPoint = currentPoint;
    
    if ([self.touchSensorLayer containsPoint:endPointAtSensorLayer] || [self.touchSensorLayer containsPoint:startPointAtSenorLayer]) {
        if ((endTime - startTime)<0.5) {
            FNCRotationType type = [self userRotationConditionWithStartPoint:startPoint andEndPoint:endPoint];
            //為了避免 Bug，因為在沒有 touchSensorLayer 加入的情況下，touchSensorLayer 仍會包括 endPointAtSensorLayer 以及 startPointAtSenorLayer
            if (isSensorLayerAdded) {
                switch (type) {
                    case kFNCClockwiseRotation:
                        [self rotationAnimationWithLayer:self.longHandLayer.superlayer inRightSideDirection:YES];
                        break;
                    case kFNCCounterClockwiseRotation:
                        [self rotationAnimationWithLayer:self.longHandLayer.superlayer inRightSideDirection:NO];
                        break;
                    default:
                        break;
                }
            }

        }else{
            if (isSensorLayerAdded) {
            [self showCheatingAlert];
            [self resetTimeAndPoint];
            [self backToOriginalState];
            }
        }
    }else{
        if (isSensorLayerAdded) {
            [self showCheatingAlert]; 
            [self resetTimeAndPoint];
            [self backToOriginalState];
        }
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesCancelled:touches withEvent:event];
}

@end
