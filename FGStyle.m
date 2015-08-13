//
//  FGStyle.m
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGStyle.h"
#import <objc/runtime.h>
#import "UIView+FGStylable.h"

@implementation FGStyle

static UIView *_view;

#define tryPerformSelectorWithObject(selectorName, arg1) \
    if ([_view respondsToSelector: @selector(selectorName :)]) {\
        [_view selectorName : arg1];\
    }

+ (void) updateStyleOfView: (UIView *) view withBlock: (FGStyleBlock) block
{
    _view = view;
    
    if ([_view respondsToSelector: @selector(beginUpdateStyle)]) {
        [_view performSelector: @selector(beginUpdateStyle)];
    }
    @try {
        if(block != nil){
            block(_view);
        }
    }
    @finally {
        @try {
            if ([_view respondsToSelector: @selector(endUpdateStyle)]) {
                [_view performSelector: @selector(endUpdateStyle)];
            }
        }@finally{
            _view = nil;
        }
    }
}

+ (void)top:(CGFloat)top
{
    tryPerformSelectorWithObject(styleWithTop, top);
}

+ (void)right:(CGFloat)right
{
    tryPerformSelectorWithObject(styleWithRight, right);
}

+ (void) bottom:(CGFloat)bottom
{
    tryPerformSelectorWithObject(styleWithBottom, bottom);
}

+ (void) left:(CGFloat)left
{
    tryPerformSelectorWithObject(styleWithLeft, left);
}

+ (void)top:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    [self top: top];
    [self right:right];
    [self bottom:bottom];
    [self left:left];
}

+ (void)topBottom:(CGFloat)topBottom leftRight:(CGFloat)leftRight
{
    [self top: topBottom];
    [self right:leftRight];
    [self bottom:topBottom];
    [self left:leftRight];
}

+ (void)height:(CGFloat)height
{
    tryPerformSelectorWithObject(styleWithHeight, height);
}

+ (void)width:(CGFloat)width
{
    tryPerformSelectorWithObject(styleWithWidth, width);
}

+ (void)aspectRatio:(CGFloat)aspectRatio
{
    tryPerformSelectorWithObject(styleWithAspectRatio, aspectRatio);
}

+ (void)topPercentage:(CGFloat)topPercentage
{
    tryPerformSelectorWithObject(styleWithTopPercentage, topPercentage);
}

+ (void)rightPercentage:(CGFloat)rightPercentage
{
    tryPerformSelectorWithObject(styleWithRightPercentage, rightPercentage);
}

+ (void) bottomPercentage:(CGFloat)bottomPercentage
{
    tryPerformSelectorWithObject(styleWithBottomPercentage, bottomPercentage);
}

+ (void) leftPercentage:(CGFloat)leftPercentage
{
    tryPerformSelectorWithObject(styleWithLeftPercentage, leftPercentage);
}

+ (void)heightPercentage:(CGFloat)heightPercentage
{
    tryPerformSelectorWithObject(styleWithHeightPercentage, heightPercentage);
}

+ (void)widthPercentage:(CGFloat)widthPercentage
{
    tryPerformSelectorWithObject(styleWithWidthPercentage, widthPercentage);
}

+ (void)textAlign:(NSTextAlignment)textAlign
{
    tryPerformSelectorWithObject(styleWithTextAlign, textAlign);
}

+ (void)fontSize:(CGFloat)fontSize
{
    tryPerformSelectorWithObject(styleWithFontSize, [NSNumber numberWithFloat: fontSize]);
}

+ (void)fontWeight:(FGStyleFontWeight)fontWeight
{
    tryPerformSelectorWithObject(styleWithFontWeight, fontWeight);
}

+ (void)lineHeight:(CGFloat)lineHeight
{
    tryPerformSelectorWithObject(styleWithLineHeight, lineHeight);
}

+ (void)color:(UIColor *)color
{
    tryPerformSelectorWithObject(styleWithColor, color);
}

+ (void)backgroundColor:(UIColor *)backgroundColor
{
    tryPerformSelectorWithObject(styleWithBackgroundColor, backgroundColor);
}

+ (void)border:(UIColor *)borderColor width:(CGFloat)borderWidth
{
    if ([_view respondsToSelector:@selector(styleWithBorder:width:)]) {
        [_view styleWithBorder:borderColor width:borderWidth];
    }
}

+ (void)borderColor:(UIColor *)borderColor
{
    tryPerformSelectorWithObject(styleWithBorderColor, borderColor);
}

+ (void)borderWidth:(CGFloat)borderWidth
{
    tryPerformSelectorWithObject(styleWithBorderWidth, borderWidth);
}

+ (void)borderRadius:(CGFloat)borderRadius
{
    tryPerformSelectorWithObject(styleWithBorderRadius, borderRadius);
}

+ (void)customStyleWithKey:(NSString *)key value:(id)value
{
    if ([_view respondsToSelector: @selector(styleWithCustomKey:value:)]) {
        [_view performSelector:@selector(styleWithCustomKey:value:) withObject:key withObject:value];
    }
}

+ (void)customStyleWithBlock:(FGStyleBlock)block
{
    if(block != nil){
        block(_view);
    }
}

+ (void) contentHuggingPriority:(UILayoutPriority) priority
{
    [_view setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisHorizontal];
    [_view setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisVertical];
}

+ (void) contentHuggingHorizontalPriority:(UILayoutPriority) horizontalPriority verticalPriority: (UILayoutPriority) verticalPriority
{
    [_view setContentHuggingPriority:horizontalPriority forAxis:UILayoutConstraintAxisHorizontal];
    [_view setContentHuggingPriority:verticalPriority forAxis:UILayoutConstraintAxisVertical];
}

+ (void) contentCompressionResistancePriority:(UILayoutPriority) priority
{
    [_view setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisHorizontal];
    [_view setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisVertical];
}

+ (void) contentCompressionResistanceHorizontalPriority:(UILayoutPriority) horizontalPriority verticalPriority: (UILayoutPriority) verticalPriority
{
    [_view setContentCompressionResistancePriority:horizontalPriority forAxis:UILayoutConstraintAxisHorizontal];
    [_view setContentCompressionResistancePriority:verticalPriority forAxis:UILayoutConstraintAxisVertical];
}

+ (void) contentMode: (UIViewContentMode) contentMode
{
    _view.contentMode = contentMode;
}

+ (void) overflow: (FGStyleOverflow) overflowMode
{
    _view.clipsToBounds = overflowMode == FGStyleOverflowHidden;
}

+ (void)horizontalCenter:(CGFloat)horizontalCenter
{
    tryPerformSelectorWithObject(styleWithHorizontalCenter, horizontalCenter);
}

+ (void)verticalCenter:(CGFloat)verticalCenter
{
    tryPerformSelectorWithObject(styleWithVerticalCenter, verticalCenter);
}

+ (void)hidden:(BOOL)hidden
{
    tryPerformSelectorWithObject(styleWithHidden, hidden);
}

+ (void)opacity:(CGFloat)opacity
{
    tryPerformSelectorWithObject(styleWithOpacity, opacity);
}

+ (void) transform: (CGAffineTransform) transform
{
    tryPerformSelectorWithObject(styleWithTransform, transform);
}

+ (void) transformOrigin:(CGPoint)transformOrigin
{
    tryPerformSelectorWithObject(styleWithTransformOrigin, transformOrigin);
}

+ (void)transition:(CGFloat)duration
{
    tryPerformSelectorWithObject(styleWithTransition, duration);
}

@end

