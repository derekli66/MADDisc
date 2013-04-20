//
//  MADBackgroundView.h
//  MadConfiguration
//
//  Created by milk on 2011/7/5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MADBackgroundView : UIView {
    UIImageView *logoMAD;
    UIImageView *logoFurnace;
}
- (void)setLogoMADWithCenterPoint:(CGPoint)p andScale:(CGFloat)s;
- (void)setLogoFurnaceWithCenterPoint:(CGPoint)p andScale:(CGFloat)s;
- (void)setLogoFurnacehide:(BOOL)h;
- (void)startLogoFurnaceAnimationWithDuration:(NSTimeInterval)d andDelay:(NSTimeInterval)dd;
@end

@interface MADBackgroundView (MADBackgroundViewAdditions)
- (void)setLogoFurnaceLayerAnimation:(CAAnimation* )theAnimation;
@end