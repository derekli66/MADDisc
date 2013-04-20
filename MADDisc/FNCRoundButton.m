//
//  FNCRoundButton.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 7/24/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "FNCRoundButton.h"

@implementation FNCRoundButton
@synthesize color = _color;
#pragma mark - Getter and Setter
-(void)setColor:(UIColor *)aColor{
    if (_color != aColor) {
        [_color release];
        _color = aColor;
        [_color retain];
        
        [self setNeedsDisplayInRect:self.frame];
    }
}
-(UIColor *)color{
    return _color;
}
#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.enabled = YES;
    }
    return self;
}
#pragma mark - Drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{   
    UIView *cornerView = [UIView cornerViewWithBorderColor:[UIColor lightGrayColor] andFrame:self.frame];
    cornerView.backgroundColor = self.color;
    UIImage *aImage = [UIView imageFromViewContents:cornerView];
    
    [aImage drawAtPoint:CGPointMake(0.0, 0.0)];
     
}
#pragma mark - Memory Management
- (void)dealloc
{
    self.color = nil;
    [super dealloc];
}

@end
