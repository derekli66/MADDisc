//
//  UIView+ImageOutput.h
//  MADDisc
//
//  Created by LI CHIEN-MING on 7/25/11.
//  Copyright 2011 Derek. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

@interface NSObject (PlistReader)
//讀取 Plist 檔案
-(NSArray*)readPlistFromBundleWithFile:(NSString*)fileName;
@end

@interface UIView (ImageOutput)
//Class method 轉換 UIView 到 UIImage
+(UIImage *)imageFromViewContents:(UIView*)theView;
//Instance method 轉換 self(UIView) 到 UIImage
-(UIImage *)imageFromCurrentContents;
//產生 corner view with border
+(UIView *)cornerViewWithBorderColor:(UIColor*)theColor andFrame:(CGRect)frame;
@end

@interface UIViewController (ImageOutput)
//Instance method 轉換 UIView 到 UIImage
-(UIImage *)imageFromViewContents:(UIView*)theView;
//Instance method 轉換 self.view(controller's view) 到 UIImage
-(UIImage *)imageFromControllerView;
@end

@interface UIControl (FNCCustomizedControlViewCategory)
+(UIControl *)cornerWithBorderColor:(UIColor*)theColor andFrame:(CGRect)frame;
@end

@interface UIColor (ImageOutput)
//依據傳入的色彩單元，再回傳 R G B 的 CGFloat 數值
enum {
    kFNCColorComponetRed = 0,
    kFNCColorComponetGreen,
    kFNCColorComponetBlue
};
typedef NSInteger FNCColorComponet;
//Claass method 猜解 UIColor 成為 color compoment R G B
+(CGFloat)colorComponetFromColor:(UIColor*)aColor inType:(FNCColorComponet)componet;
@end