//
//  FNCCheckItemView.m
//  FNCCustomTableCell
//
//  Created by LI CHIEN-MING on 7/12/11.
//  Copyright 2011 Derek. All rights reserved.
//
#import "FNCCheckItemView.h"

#define SHOW_CURRENT_METHOD NSLog(@"%@", NSStringFromSelector(_cmd))

@interface FNCCheckItemView()
-(UIView *)userColorViewWithColor:(UIColor*)theColor;
-(NSString*)possibilityTextOnPossibility:(FNCPossibility)possibility;
@end

@implementation FNCCheckItemView
@synthesize managedObject = __managedObject;
@synthesize highlighted = _highlighted;
@synthesize editing = _editing;
#pragma mark - Getter and Setter
- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (_highlighted != lit) {
		_highlighted = lit;
		[self setNeedsDisplay];
	}
}
-(void)setManagedObject:(NSManagedObject *)theDecisionObject{
    if (theDecisionObject != __managedObject) {
        [__managedObject release];
        __managedObject = theDecisionObject;
        [__managedObject retain];
        
        [self setNeedsDisplay];
    }
}
-(void)setViewStateMask:(FNCCellState)currentState{
    if (viewStateMask != currentState) {
        viewStateMask = currentState;
        [self setNeedsDisplay];
    }
}
#pragma mark - Custom Methods
-(UIView *)userColorViewWithColor:(UIColor*)theColor{
    UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
    theView.backgroundColor = theColor;
    theView.layer.cornerRadius = 8;
    theView.layer.borderWidth = 1.8;
    theView.layer.borderColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1].CGColor;
    theView.layer.masksToBounds = YES;
    
    return [theView autorelease];
}
-(NSString*)possibilityTextOnPossibility:(FNCPossibility)possibility{
    NSString *stringLow = NSLocalizedString(@"-Low", @"Low 機率 低") ;//**@@** Internalization
    NSString *stringMedium =NSLocalizedString(@"-Medium", @"Medium 機率 一般") ;//**@@** Internalization
    NSString *stringHigh =NSLocalizedString(@"-High", @"High 機率 高") ; //**@@** Internalization
    
    switch (possibility) {
        case kFNCPossibilityLow:
            return [stringLow substringFromIndex:1]; 
            break;
        case kFNCPossibilityMedium: 
            return [stringMedium substringFromIndex:1];
            break;
        case kFNCPossibilityHigh: 
            return [stringHigh substringFromIndex:1];
            break;
            
        default:
            break;
    }
    return @"Undefined";
}

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
        viewStateMask = kFNCCellStateDefaultMask;
    }
    return self;
}

#pragma mark - Drawing View
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
#define MAIN_FONT_SIZE 20
#define MIN_MAIN_FONT_SIZE 18
#define SECONDARY_FONT_SIZE 16
#define MIN_SECONDARY_FONT_SIZE 14
    
#define MAIN_WIDTH 180
#define SECONDARY_WIDTH 80 
    
#define UPPER_ROW_TOP 3
#define LOWER_ROW_TOP 26
#define LEFT_EDGE_SPACE 55
#define IMAGE_TOP 7
#define IN_BETWEEN_SPACE 60
    
#define SHIFT_LEFT_SPACE 30

    Decision *decision = (Decision*)self.managedObject;
    NSString *userChoiceString = decision.name;
    NSString *userPossibility = [self possibilityTextOnPossibility:[decision.possibility integerValue]];
    UIImage *colorViewImage = [UIView imageFromViewContents:[self userColorViewWithColor:(UIColor*)decision.color]];
    
	UIColor *mainTextColor = nil;
	//UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    UIFont *mainFont = [UIFont fontWithName:@"Helvetica-Bold" size:MAIN_FONT_SIZE];
    
	UIColor *secondaryTextColor = nil;
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
    
    // Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
		secondaryTextColor = [UIColor whiteColor];
	}
	else {
		mainTextColor = [UIColor blackColor];
		secondaryTextColor = [UIColor darkGrayColor];
		self.backgroundColor = [UIColor clearColor];
	}
    
    if (!self.editing) {
		CGPoint point;
        
        point = CGPointMake(LEFT_EDGE_SPACE, UPPER_ROW_TOP);
        [mainTextColor set];
        if (viewStateMask == kFNCCellStateNone || viewStateMask == kFNCCellStateShowingDeleteConfirmationMask) {
            [userChoiceString drawAtPoint:point forWidth:(MAIN_WIDTH - SHIFT_LEFT_SPACE) withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        }else{
            [userChoiceString drawAtPoint:point forWidth:MAIN_WIDTH withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        }

        point = CGPointMake(LEFT_EDGE_SPACE, LOWER_ROW_TOP);
        [secondaryTextColor set];
        [userPossibility drawAtPoint:point forWidth:SECONDARY_WIDTH withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        
        if (viewStateMask == kFNCCellStateNone || viewStateMask == kFNCCellStateShowingDeleteConfirmationMask) {
            point = CGPointMake(MAIN_WIDTH + SHIFT_LEFT_SPACE, IMAGE_TOP);
            [colorViewImage drawAtPoint:point];
        }else{
            point = CGPointMake(MAIN_WIDTH + IN_BETWEEN_SPACE, IMAGE_TOP);
            [colorViewImage drawAtPoint:point];
        }
        NSLog(@"viewStateMask %d", viewStateMask);
    }
    
}
#pragma mark - Memory Management
- (void)dealloc
{
    self.managedObject = nil;
    [super dealloc];
}

@end
