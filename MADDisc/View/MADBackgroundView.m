//
//  MADBackgroundView.m
//  MadConfiguration
//
//  Created by milk on 2011/7/5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MADBackgroundView.h"

@implementation MADBackgroundView
//For Initialization from XIB file. Designate initializer.
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);//從 Nib initialized 之後，設定 frame 大小
        
        //設定背景
        UIImage *pattern = [UIImage imageNamed:@"MADBackground.png"];
        [self setBackgroundColor:[UIColor colorWithPatternImage:pattern]];
        
        //設定MADlogo
        logoMAD = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppLogo.png"]];
        logoMAD.frame = CGRectMake(0.0, 0.0, 208.0, 94.0);
        
        CGPoint point = CGPointMake(160.0, 425.0);
        [self setLogoMADWithCenterPoint:point andScale:1.0];
        
        [self addSubview:logoMAD];
            
        //設定Furnacelogo
        logoFurnace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FurnaceLogo.png"]];
        logoFurnace.frame = CGRectMake(0.0, 0.0, 256.0, 256.0);
        
        point = CGPointMake(160.0, 200.0);
        [self setLogoFurnaceWithCenterPoint:point andScale:1.0];
        
        [self addSubview:logoFurnace];
        
        //產生logoFurnace動畫
        //[self startLogoFurnaceAnimationWithDuration:1 andDelay:1];
    }
    return self;
}
//Doing Initialization programmingly. Designate initializer.
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    if (self) {
        
        //設定背景
        UIImage *pattern = [UIImage imageNamed:@"MADBackground.png"];
        [self setBackgroundColor:[UIColor colorWithPatternImage:pattern]];
        
        //設定MADlogo
        logoMAD = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppLogo.png"]];
        logoMAD.frame = CGRectMake(0.0, 0.0, 208.0, 94.0);
        
        CGPoint point = CGPointMake(160.0, 425.0);
        [self setLogoMADWithCenterPoint:point andScale:1.0];
        
        [self addSubview:logoMAD];
        
        //設定Furnacelogo
        logoFurnace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FurnaceLogo.png"]];
        logoFurnace.frame = CGRectMake(0.0, 0.0, 256.0, 256.0);
        
        point = CGPointMake(160.0, 200.0);
        [self setLogoFurnaceWithCenterPoint:point andScale:1.0];
        
        [self addSubview:logoFurnace];
        
        //產生logoFurnace動畫
        //[self startLogoFurnaceAnimationWithDuration:1 andDelay:1];
    }
    return self;
}

- (id)init {
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    self = [self initWithFrame:frame];//Invoke designate initializer
    if (self) {
        
    }
    return self;
}

- (void)setLogoMADWithCenterPoint:(CGPoint)p andScale:(CGFloat)s {
    logoMAD.center = p;
    logoMAD.transform =CGAffineTransformMakeScale(s,s);
}

- (void)setLogoFurnaceWithCenterPoint:(CGPoint)p andScale:(CGFloat)s {
    logoFurnace.center = p;
    logoFurnace.transform =CGAffineTransformMakeScale(s,s);
}

- (void)setLogoFurnacehide:(BOOL)h {
    logoFurnace.hidden = h;
}

- (void)startLogoFurnaceAnimationWithDuration:(NSTimeInterval)d andDelay:(NSTimeInterval)dd {
    [UIView beginAnimations:@"logoFurnaceAnimation" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:d];
    [UIView setAnimationDelay:dd];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGPoint point = CGPointMake(logoFurnace.center.x, logoFurnace.center.y);
    [self setLogoFurnaceWithCenterPoint:point andScale:0.05];
    
    [UIView setAnimationDidStopSelector:@selector(setLogoFurnacehide:)];
    [UIView commitAnimations];
}

- (void)dealloc
{
    [logoMAD release];
    [logoFurnace release];
    [super dealloc];
}
@end

@implementation MADBackgroundView (MADBackgroundViewAdditions)
- (void)setLogoFurnaceLayerAnimation:(CAAnimation* )theAnimation{
    [logoFurnace.layer addAnimation:theAnimation forKey:@"LogoFurnaceLayerAnimation"];
}
@end
