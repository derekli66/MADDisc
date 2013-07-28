//
//  PieChart.m
//
//  Created by Dain on 7/23/10.
//  Copyright 2010 Dain Kaplan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PieChartView.h"
#import "Decision.h"

static BOOL isDefaultPieChartOn = NO;

#define SHOW_CURRENT_METHOD NSLog(@"%@", NSStringFromSelector(_cmd))

@interface PieChartItem : NSObject
{
	PieChartItemColor _color;
	float _value;
}

@property (nonatomic, assign) PieChartItemColor color;
@property (nonatomic, assign) float value;
@end

@implementation PieChartItem

- (id)init
{	self = [super init];
    if (self) {
		_value = 0.0;
	}
	return self;
}

@synthesize color = _color;
@synthesize value = _value;

@end


@interface PieChartView()
// Private interface
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
- (UIImage *)createCircleMaskUsingCenterPoint:(CGPoint)point andRadius:(float)radius;
- (UIImage *)createGradientImageUsingRect:(CGRect)rect;
//以下為新增的兩個方法，作為畫出正常圓餅以及預設圓餅(沒有任何選擇的時候)
- (void)drawNormalPieChartWithX:(NSInteger)x andY:(NSInteger)y andRadius:(NSInteger)r andContext:(CGContextRef)ctx;
- (void)drawDefaultPieChartWithX:(NSInteger)x andY:(NSInteger)y andRadius:(NSInteger)r andContext:(CGContextRef)ctx;
@end

@implementation PieChartView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)aRect
{	self = [super initWithFrame:aRect];
    if (self) {
		_gradientFillColor = PieChartItemColorMake(0.1, 0.1, 0.1, 0.4);
		_gradientStart = 0.3;
		_gradientEnd = 1.0;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

// XXX: In the case this view is being loaded from a NIB/XIB (and not programmatically)
// initWithCoder is called instead of initWithFrame:
- (id)initWithCoder:(NSCoder *)decoder
{	self = [super initWithCoder:decoder];
    if (self) {
		_gradientFillColor = PieChartItemColorMake(0.1, 0.1, 0.1, 0.4);
		_gradientStart = 0.3;
		_gradientEnd = 1.0;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)clearItems 
{
	if( _pieItems ) {
		[_pieItems removeAllObjects];	
	}
	
	_sum = 0.0;
}

- (void)addItemValue:(float)value withColor:(PieChartItemColor)color
{
	PieChartItem *item = [[PieChartItem alloc] init];
	
	item.value = value;
	item.color = color;
	
	if( !_pieItems ) {
		_pieItems = [[NSMutableArray alloc] initWithCapacity:10];
	}
	
	[_pieItems addObject:item];
	
	[item release];
	
	_sum += value;
}

- (void)setNoDataFillColorRed:(float)r green:(float)g blue:(float)b
{
	_noDataFillColor = PieChartItemColorMake(r, g, b, 1.0);
}

- (void)setNoDataFillColor:(PieChartItemColor)color
{
	_noDataFillColor = color;
}

- (void)setGradientFillColorRed:(float)r green:(float)g blue:(float)b
{
	_gradientFillColor = PieChartItemColorMake(r, g, b, 0.4);
}

- (void)setGradientFillColor:(PieChartItemColor)color
{
	_gradientFillColor = color;
}

- (void)setGradientFillStart:(float)start andEnd:(float)end
{
	_gradientStart = start;
	_gradientEnd = end;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

	
	int x = self.center.x;
	int y = self.center.y;
	int r = (self.bounds.size.width > self.bounds.size.height?self.bounds.size.height:self.bounds.size.width)/2 * 0.92;
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (isDefaultPieChartOn == NO) {
            [self drawNormalPieChartWithX:x andY:y andRadius:r andContext:ctx];
    }else{
        [self drawDefaultPieChartWithX:x andY:y andRadius:r andContext:ctx];
    }

	
    isDefaultPieChartOn = NO; //reset the isDefaultPieChartOn to NO.
    
	// Now we want to create an overlay for the gradient to make it look *fancy*
	// We do this by:
	// (0) Create circle mask
	// (1) Creating a blanket gradient image the size of the piechart
	// (2) Masking the gradient image with a circle the same size as the piechart
	// (3) compositing the gradient onto the piechart
	
	// (0)
	UIImage *maskImage = [self createCircleMaskUsingCenterPoint: CGPointMake(x, y) andRadius: r];
	
	// (1)
	UIImage *gradientImage = [self createGradientImageUsingRect: self.bounds];
	
	// (2)
	UIImage *fadeImage = [self maskImage:gradientImage withMask:maskImage];
	
	// (3)
	CGContextDrawImage(ctx, self.bounds, fadeImage.CGImage);

	// Finally set shadows
    
	self.layer.shadowRadius = 10;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.7;
	self.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    
}
-(void)drawDefaultPieChartWithX:(NSInteger)x andY:(NSInteger)y andRadius:(NSInteger)r andContext:(CGContextRef)ctx{
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.3);
	CGContextSetLineWidth(ctx, 1.0);
	
	// Draw a thin line around the circle
	CGContextAddArc(ctx, x, y, r, 0.0, 360.0*M_PI/180.0, 0);
	CGContextClosePath(ctx);
	CGContextDrawPath(ctx, kCGPathStroke);
    
    NSUInteger idx = 0;
	for( idx = 0; idx < [_pieItems count]; idx++ ) {
		PieChartItem *item = [_pieItems objectAtIndex:idx];
		
		PieChartItemColor color = item.color;
        
        CGContextSetRGBFillColor(ctx, color.red, color.green, color.blue, color.alpha);
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddArc(ctx, x, y, r - 22*idx, 0.0, 2*M_PI, 0);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
	}
}
- (void)drawNormalPieChartWithX:(NSInteger)x andY:(NSInteger)y andRadius:(NSInteger)r andContext:(CGContextRef)ctx{
    float startDeg = 0;
	float endDeg = 0;
    
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.3);
	CGContextSetLineWidth(ctx, 1.0);
	
	// Draw a thin line around the circle
	CGContextAddArc(ctx, x, y, r, 0.0, 360.0*M_PI/180.0, 0);
	CGContextClosePath(ctx);
	CGContextDrawPath(ctx, kCGPathStroke);
	
	// Loop through all the values and draw the graph
	startDeg = 0;
	
	//NSLog(@"Total of %d pie items to draw.", [_pieItems count]);
	
    NSMutableArray *anglesArray = [NSMutableArray arrayWithCapacity:[_pieItems count]];
	NSUInteger idx = 0;
	for( idx = 0; idx < [_pieItems count]; idx++ ) {
		
		PieChartItem *item = [_pieItems objectAtIndex:idx];
		
		PieChartItemColor color = item.color;
		float currentValue = item.value;
		
		float theta = (360.0 * (currentValue/_sum));
		
		if( theta > 0.0 ) {
			endDeg += theta;
			
			//NSLog(@"Drawing arc [%d] from %f to %f.", idx, startDeg, endDeg);
			
			if( startDeg != endDeg ) {
				CGContextSetRGBFillColor(ctx, color.red, color.green, color.blue, color.alpha );
				CGContextMoveToPoint(ctx, x, y);
				CGContextAddArc(ctx, x, y, r, (startDeg-90)*M_PI/180.0, (endDeg-90)*M_PI/180.0, 0);
				CGContextClosePath(ctx);
				CGContextFillPath(ctx);
                NSArray *degRangeArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:startDeg], [NSNumber numberWithFloat:endDeg],nil];
                [anglesArray addObject:degRangeArray];
			}
		}
		
		startDeg = endDeg;
	}
	//通知 delegate 所產生的 每一個區塊的 angles 為何
    [self.delegate imageViewWithPieAngles:anglesArray];
	// Draw the remaining portion as a no-data-fill color, though there should never be one. (current code doesn't allow it)
	if( endDeg < 360.0 ) {
		
		startDeg = endDeg;
		endDeg = 360.0;
		
		//NSLog(@"Drawing bg arc from %f to %f.", startDeg, endDeg);
		
		if( startDeg != endDeg ) {
			CGContextSetRGBFillColor(ctx, _noDataFillColor.red, _noDataFillColor.green, _noDataFillColor.blue, _noDataFillColor.alpha );
			CGContextMoveToPoint(ctx, x, y);
			CGContextAddArc(ctx, x, y, r, (startDeg-90)*M_PI/180.0, (endDeg-90)*M_PI/180.0, 0);
			CGContextClosePath(ctx);
			CGContextFillPath(ctx);
		}	
	}
}
- (UIImage *)createCircleMaskUsingCenterPoint:(CGPoint)point andRadius:(float)radius
{
	UIGraphicsBeginImageContext( self.bounds.size );
	CGContextRef ctx2 = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(ctx2, 1.0, 1.0, 1.0, 1.0 );
	CGContextFillRect(ctx2, self.bounds);
	CGContextSetRGBFillColor(ctx2, 0.0, 0.0, 0.0, 1.0 );
	CGContextMoveToPoint(ctx2, point.x, point.y);
	CGContextAddArc(ctx2, point.x, point.y, radius, 0.0, (360.0)*M_PI/180.0, 0);
	CGContextClosePath(ctx2);
	CGContextFillPath(ctx2);
	UIImage *maskImage = [[UIGraphicsGetImageFromCurrentImageContext() retain] autorelease];
	UIGraphicsPopContext();
	
	return maskImage;
}

// Shout out to: http://stackoverflow.com/questions/422066/gradients-on-uiview-and-uilabels-on-iphone
- (UIImage *)createGradientImageUsingRect:(CGRect)rect
{
	UIGraphicsBeginImageContext( rect.size );
	CGContextRef ctx3 = UIGraphicsGetCurrentContext();
	
	size_t locationsCount = 2;
    CGFloat locations[2] = { 1.0-_gradientStart, 1.0-_gradientEnd };
    CGFloat components[8] = { /* loc 2 */ 0.0, 0.0, 0.0, 0.0, /* loc 1 */ _gradientFillColor.red, _gradientFillColor.green, _gradientFillColor.blue, _gradientFillColor.alpha };
	
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, locationsCount);
	
    CGRect currentBounds = rect;
    CGPoint topCenterPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMinY(currentBounds));
    CGPoint bottomCenterPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextDrawLinearGradient(ctx3, gradient, topCenterPoint, bottomCenterPoint, 0);
	
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace); 
	UIImage *gradientImage = [[UIGraphicsGetImageFromCurrentImageContext() retain] autorelease];
	UIGraphicsPopContext();
	
	return gradientImage;
}

// Masks one image with another
// Shout out to: http://iphonedevelopertips.com/cocoa/how-to-mask-an-image.html
- (UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	
	CGImageRef maskRef = maskImage.CGImage; 
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	UIImage *ret = [UIImage imageWithCGImage:masked];
	CGImageRelease(masked);
	CGImageRelease(mask);
	return ret;
}

- (void)dealloc {
	[_pieItems release];
    [super dealloc];
}
@end

@implementation PieChartView (FNCPieGraphController)
-(void)createDefaultPieChart{
    isDefaultPieChartOn = YES; //設定 isDefaultPieChartOn 為 YES，讓drawRect method 內部進行判斷要做何種繪圖
    
    [self addItemValue:0.1 withColor:PieChartItemColorMake(230/255.0, 0.0, 18/255.0, 0.75)]; //紅色
    [self addItemValue:0.1 withColor:PieChartItemColorMake(234/255.0, 84/255.0, 19/255.0, 0.75)]; //橘色
    [self addItemValue:0.1 withColor:PieChartItemColorMake(247/255.0, 238/255.0, 19/255.0, 0.75)]; //黃色
    [self addItemValue:0.1 withColor:PieChartItemColorMake(7/255.0, 145/255.0, 58/255.0, 0.75)]; //綠色
    [self addItemValue:0.1 withColor:PieChartItemColorMake(14/255.0, 110/255.0, 184/255.0, 0.75)]; //藍色
    [self addItemValue:0.1 withColor:PieChartItemColorMake(23/255.0, 28/255.0, 97/255.0, 0.75)]; //靛色
}
//需要根據 主程式內的 UserDefault 內容做改寫
-(void)createPieChartWithPossibilityValueArray:(NSArray*)valueArray andUserDefaultArray:(NSArray*)userArray{

    static int idx = 0;
    
    for (Decision *item in userArray) {
        UIColor *color = item.color;
        const CGFloat *c = CGColorGetComponents(color.CGColor);
        [self addItemValue:[[valueArray objectAtIndex:idx] floatValue] withColor:PieChartItemColorMake(c[0], c[1], c[2], 0.75)];
        idx++;
    }
    [self setNeedsDisplay];
    idx = 0;
}
@end
