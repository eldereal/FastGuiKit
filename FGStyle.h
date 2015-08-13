//
//  FGStyle.h
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGTypes.h"

typedef NS_ENUM(NSUInteger, FGStyleFontWeight)
{
    FGStyleFontWeightNormal = 0,
    FGStyleFontWeightBold
};

typedef NS_ENUM(NSUInteger, FGStyleOverflow)
{
    FGStyleOverflowVisible = 0,
    FGStyleOverflowHidden
};

@protocol FGStylable <NSObject>

@optional

- (void) styleWithLeft: (CGFloat) left;

- (void) styleWithRight: (CGFloat) right;

- (void) styleWithTop: (CGFloat) top;

- (void) styleWithBottom: (CGFloat) bottom;

- (void) styleWithWidth: (CGFloat) width;

- (void) styleWithHeight: (CGFloat) height;

- (void) styleWithAspectRatio: (CGFloat) aspectRatio;

- (void) styleWithHorizontalCenter: (CGFloat) horizontalCenter;

- (void) styleWithVerticalCenter: (CGFloat) verticalCenter;

- (void) styleWithLeftPercentage: (CGFloat) leftPercentage;

- (void) styleWithRightPercentage: (CGFloat) rightPercentage;

- (void) styleWithTopPercentage: (CGFloat) topPercentage;

- (void) styleWithBottomPercentage: (CGFloat) bottomPercentage;

- (void) styleWithWidthPercentage: (CGFloat) widthPercentage;

- (void) styleWithHeightPercentage: (CGFloat) heightPercentage;

- (void) styleWithTextAlign: (NSTextAlignment) textAlign;

- (void) styleWithFontSize: (NSNumber *) fontSize;

- (void) styleWithFontWeight: (FGStyleFontWeight) fontWeight;

- (void) styleWithLineHeight: (CGFloat)lineHeight;

- (void) styleWithColor: (UIColor *) color;

- (void) styleWithBackgroundColor: (UIColor *) backgroundColor;

- (void) styleWithBorder: (UIColor *) color width: (CGFloat) borderWidth;

- (void) styleWithBorderColor: (UIColor *) borderColor;

- (void) styleWithBorderWidth: (CGFloat) borderWidth;

- (void) styleWithBorderRadius: (CGFloat) borderRadius;

- (void) styleWithCustomKey: (NSString *) key value: (id) value;

- (void) styleWithOpacity: (CGFloat) opacity;

- (void) styleWithHidden: (CGFloat) hidden;

- (void) styleWithTransform: (CGAffineTransform) transform;

- (void) styleWithTransformOrigin: (CGPoint) transformOrigin;

- (void) styleWithTransition: (CGFloat) duration;

- (void) beginUpdateStyle;

- (void) endUpdateStyle;

@end

@protocol FGStyleSheet

- (void) styleSheet;

@end

@interface FGStyle : NSObject

+ (void) updateStyleOfView: (UIView *) view withBlock: (FGStyleBlock) block;

+ (void) left: (CGFloat) left;

+ (void) top: (CGFloat) top;

+ (void) bottom: (CGFloat) bottom;

+ (void) right: (CGFloat) right;

+ (void) width: (CGFloat) width;

+ (void) height: (CGFloat) height;

+ (void) aspectRatio: (CGFloat) aspectRatio;

+ (void) top: (CGFloat) top right: (CGFloat) right bottom: (CGFloat) bottom left: (CGFloat) left;

+ (void) topBottom: (CGFloat) topBottom leftRight: (CGFloat) leftRight;

+ (void) leftPercentage: (CGFloat) leftPercentage;

+ (void) topPercentage: (CGFloat) topPercentage;

+ (void) bottomPercentage: (CGFloat) bottomPercentage;

+ (void) rightPercentage: (CGFloat) rightPercentage;

+ (void) widthPercentage: (CGFloat) widthPercentage;

+ (void) heightPercentage: (CGFloat) heightPercentage;

+ (void) horizontalCenter: (CGFloat) horizontalCenter;

+ (void) verticalCenter: (CGFloat) verticalCenter;

+ (void) textAlign: (NSTextAlignment) textAlign;

+ (void) fontSize: (CGFloat) fontSize;

+ (void) fontWeight: (FGStyleFontWeight) fontWeight;

+ (void) lineHeight: (CGFloat)lineHeight;

+ (void) color: (UIColor *) color;

+ (void) backgroundColor: (UIColor *) backgroundColor;

+ (void) border: (UIColor *) borderColor width: (CGFloat) borderWidth;

+ (void) borderColor: (UIColor *) borderColor;

+ (void) borderWidth: (CGFloat) borderWidth;

+ (void) borderRadius: (CGFloat) borderRadius;

+ (void) customStyleWithKey: (NSString *) key value: (id) value;

+ (void) customStyleWithBlock: (FGStyleBlock) block;

+ (void) contentHuggingPriority:(UILayoutPriority) priority;

+ (void) contentHuggingHorizontalPriority:(UILayoutPriority) horizontalPriority verticalPriority: (UILayoutPriority) verticalPriority;

+ (void) contentCompressionResistancePriority:(UILayoutPriority) priority;

+ (void) contentCompressionResistanceHorizontalPriority:(UILayoutPriority) horizontalPriority verticalPriority: (UILayoutPriority) verticalPriority;

+ (void) contentMode: (UIViewContentMode) contentMode;

+ (void) overflow: (FGStyleOverflow) overflowMode;

+ (void) hidden: (BOOL) hidden;

+ (void) opacity: (CGFloat) opacity;

+ (void) transform: (CGAffineTransform) transform;

+ (void) transformOrigin: (CGPoint) transformOrigin;

+ (void) transition: (CGFloat) duration;

@end
