//
//  FNCCALayerDrawingDelegate.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 7/15/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "FNCCALayerDrawingDelegate.h"

#define SHOW_CURRENT_METHOD NSLog(@"%@", NSStringFromSelector(_cmd))

@implementation FNCCALayerDrawingDelegate
@synthesize frame = _frame;
#pragma mark - CALayer Drawing Delegate
//longHandLayer delegate method to draw long hand layer
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    SHOW_CURRENT_METHOD;
    //Draw a line
    
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 11.0);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2);
    CGContextAddLineToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    
    //Draw a Arrow
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4);
    CGContextAddLineToPoint(ctx, 1.0, layer.frame.size.height/4+17.0);
    CGContextAddLineToPoint(ctx, layer.frame.size.width/2, 2.0);
    CGContextAddLineToPoint(ctx, layer.frame.size.width -1.0, layer.frame.size.height/4+17.0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    
    //Draw a center circle
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2);
    CGContextAddArc(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2, layer.frame.size.width/2-2, 0, M_PI*2, 1);
    NSLog(@"x %f", layer.frame.size.width/2);
    NSLog(@"y %f", layer.frame.size.height - layer.frame.size.width/2);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    //Draw a inner circle
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetAlpha(ctx, 0.8);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2);
    CGContextAddArc(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2, 7.0, 0, M_PI*2, 1);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    //Draw a inner circle ring
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7].CGColor);
    CGContextSetAlpha(ctx, 0.8);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextAddArc(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2, 8.0, 0, M_PI*2, 1);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //Draw a center vertical line
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7].CGColor);
    CGContextSetAlpha(ctx, 0.2);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2 - 9.5);
    CGContextAddLineToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4-11);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //Draw a center vertical line
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7].CGColor);
    CGContextSetAlpha(ctx, 0.7);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height - layer.frame.size.width/2 - 9.5);
    CGContextAddLineToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4-10);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //Draw triple lines
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7].CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetAlpha(ctx, 0.6);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4-10);
    CGContextAddLineToPoint(ctx, 2.0, layer.frame.size.height/4+16.0);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4-10);
    CGContextAddLineToPoint(ctx, layer.frame.size.width/2, 3.0);
    CGContextMoveToPoint(ctx, layer.frame.size.width/2, layer.frame.size.height/4-10);
    CGContextAddLineToPoint(ctx, layer.frame.size.width -2.0, layer.frame.size.height/4+16.0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
     
}
@end
