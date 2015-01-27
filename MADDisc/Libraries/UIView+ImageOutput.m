//
//  UIView+ImageOutput.m
//  MADDisc
//
//  Created by LI CHIEN-MING on 7/25/11.
//  Copyright 2011 Derek. All rights reserved.
//

#import "UIView+ImageOutput.h"
@implementation NSObject (PlistReader)
//Read Plist file from bundle
- (NSArray*)readPlistFromBundleWithFile:(NSString*)fileName
{
    NSString *string = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:string];
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    NSDictionary *startUpArray = (NSDictionary *)[NSPropertyListSerialization
                                                  propertyListFromData:plistData
                                                  mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                  format:&format
                                                  errorDescription:&errorDesc];
    if ([startUpArray isKindOfClass:[NSArray class]]) {
        NSLog(@"startUpArray is a kind of NSArray!");
    }
    
    if ([startUpArray isKindOfClass:[NSDictionary class]]) {
        NSLog(@"startUpArray is a kind of NSDictionary");
    }
    
    NSArray *rootArray = [startUpArray objectForKey:@"Root"];
    
    return rootArray;
}
@end

@implementation UIView (ImageOutput)
//Transform any UIView or UIView subclass into UIImage
+ (UIImage *)imageFromViewContents:(UIView *)theView
{
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(theView.bounds.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(theView.bounds.size);
    
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

//Transform any UIView or UIView subclass itself into UIImage
- (UIImage *)imageFromCurrentContents{
    if (&UIGraphicsBeginImageContextWithOptions) 
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

//create a round corner UIView or UIView subclass with border
+ (UIView *)cornerViewWithBorderColor:(UIColor*)theColor andFrame:(CGRect)frame{
    UIView *theView = [[UIView alloc] initWithFrame:frame];
    theView.layer.cornerRadius = 4;
    theView.layer.borderWidth = 1.5;
    theView.layer.borderColor = theColor.CGColor;
    theView.layer.masksToBounds = YES;
    
    return [theView autorelease];
}
@end

@implementation UIViewController (ImageOutput)
//Transform any UIView or UIView subclass into UIImage
- (UIImage *)imageFromViewContents:(UIView*)theView
{
    if (&UIGraphicsBeginImageContextWithOptions) 
        UIGraphicsBeginImageContextWithOptions(theView.bounds.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(theView.bounds.size);
    
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

//Transform controller itself's view into UIImage 
- (UIImage *)imageFromControllerView
{
    if (&UIGraphicsBeginImageContextWithOptions) 
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    else
        UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myImage;
}

@end

@implementation UIControl (FNCCustomizedControlViewCategory)
+ (UIControl *)cornerWithBorderColor:(UIColor*)theColor andFrame:(CGRect)frame
{
    UIControl *theControl = [[UIControl alloc] initWithFrame:frame];
    theControl.layer.cornerRadius = 4;
    theControl.layer.borderWidth = 2.0;
    theControl.layer.borderColor = theColor.CGColor;
    theControl.layer.masksToBounds = YES;
    
    return [theControl autorelease];
}
@end

@implementation UIColor (ImageOutput)
+ (CGFloat)colorComponetFromColor:(UIColor*)aColor inType:(FNCColorComponet)componet
{
    if (aColor == nil) {
        aColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
    const CGFloat *c = CGColorGetComponents(aColor.CGColor);
    switch (componet) {
        case kFNCColorComponetRed: return c[0]; break;
        case kFNCColorComponetGreen: return c[1]; break;
        case kFNCColorComponetBlue: return c[2]; break;
    }
    return c[0];
}
@end