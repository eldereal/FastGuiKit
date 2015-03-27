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
    if([_view respondsToSelector:@selector(styleWithTop:)])
    {
        [_view styleWithTop: top];
    }
}

+ (void)right:(CGFloat)right
{
    if([_view respondsToSelector:@selector(styleWithRight:)])
    {
        [_view styleWithRight: right];
    }
}

+ (void) bottom:(CGFloat)bottom
{
    if([_view respondsToSelector:@selector(styleWithBottom:)])
    {
        [_view styleWithBottom: bottom];
    }
}

+ (void) left:(CGFloat)left
{
    if([_view respondsToSelector:@selector(styleWithLeft:)])
    {
        [_view styleWithLeft: left];
    }
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
    if([_view respondsToSelector:@selector(styleWithHeight:)])
    {
        [_view styleWithHeight: height];
    }
}

+ (void)width:(CGFloat)width
{
    if([_view respondsToSelector:@selector(styleWithWidth:)])
    {
        [_view styleWithWidth: width];
    }
}

+ (void)topPercentage:(CGFloat)topPercentage
{
    if([_view respondsToSelector:@selector(styleWithTopPercentage:)])
    {
        [_view styleWithTopPercentage: topPercentage];
    }
}

+ (void)rightPercentage:(CGFloat)rightPercentage
{
    if([_view respondsToSelector:@selector(styleWithRightPercentage:)])
    {
        [_view styleWithRightPercentage: rightPercentage];
    }
}

+ (void) bottomPercentage:(CGFloat)bottomPercentage
{
    if([_view respondsToSelector:@selector(styleWithBottomPercentage:)])
    {
        [_view styleWithBottomPercentage: bottomPercentage];
    }
}

+ (void) leftPercentage:(CGFloat)leftPercentage
{
    if([_view respondsToSelector:@selector(styleWithLeftPercentage:)])
    {
        [_view styleWithLeftPercentage: leftPercentage];
    }
}

+ (void)heightPercentage:(CGFloat)heightPercentage
{
    if([_view respondsToSelector:@selector(styleWithHeightPercentage:)])
    {
        [_view styleWithHeightPercentage: heightPercentage];
    }
}

+ (void)widthPercentage:(CGFloat)widthPercentage
{
    if([_view respondsToSelector:@selector(styleWithWidthPercentage:)])
    {
        [_view styleWithWidthPercentage: widthPercentage];
    }
}

+ (void)fontSize:(CGFloat)fontSize
{
    if ([_view respondsToSelector: @selector(styleWithFontSize:)]) {
        [_view performSelector:@selector(styleWithFontSize:) withObject:[NSNumber numberWithFloat: fontSize]];
    }else if ([_view respondsToSelector:@selector(font)] && [_view respondsToSelector: @selector(setFont:)]) {
        id ret = [_view performSelector:@selector(font)];
        if ([ret isKindOfClass:[UIFont class]]) {
            UIFont *newFont = [(UIFont *)ret fontWithSize:fontSize];
            [_view performSelector:@selector(setFont:) withObject:newFont];
        }
    }
}

+ (void)fontWeight:(FGStyleFontWeight)fontWeight
{
    if ([_view respondsToSelector:@selector(styleWithFontWeight:)]) {
        [_view styleWithFontWeight:fontWeight];
    }else if ([_view respondsToSelector:@selector(font)] && [_view respondsToSelector: @selector(setFont:)]) {
        id ret = [_view performSelector:@selector(font)];
        if ([ret isKindOfClass:[UIFont class]]) {
            UIFont *oldFont = (UIFont *)ret;
            UIFont *newFont;
            if (fontWeight == FGStyleFontWeightNormal) {
                newFont = [UIFont fontWithDescriptor:[oldFont.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:0];
            }else{
                newFont = [UIFont fontWithDescriptor:[oldFont.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0];
            }
            [_view performSelector:@selector(setFont:) withObject:newFont];
        }
    }
}

+ (void)color:(UIColor *)color
{
    if ([_view respondsToSelector: @selector(styleWithColor:)]) {
        [_view performSelector:@selector(styleWithColor:) withObject:color];
    }else{
        _view.tintColor = color;
    }
}

+ (void)backgroundColor:(UIColor *)backgroundColor
{
    if ([_view respondsToSelector: @selector(styleWithBackgroundColor:)]) {
        [_view performSelector:@selector(styleWithBackgroundColor:) withObject:backgroundColor];
    }else{
        _view.backgroundColor = backgroundColor;
    }
}

+ (void)border:(UIColor *)borderColor width:(CGFloat)borderWidth
{
    _view.layer.borderWidth = borderWidth;
    _view.layer.borderColor = borderColor.CGColor;
}

+ (void) borderRadius:(CGFloat)borderRadius
{
    _view.layer.cornerRadius = borderRadius;
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

+ (void)horizontalCenter:(CGFloat)horizontalCenter
{
    if ([_view respondsToSelector:@selector(styleWithHorizontalCenter:)]) {
        [_view styleWithHorizontalCenter:horizontalCenter];
    }
}

+ (void)verticalCenter:(CGFloat)verticalCenter
{
    if ([_view respondsToSelector:@selector(styleWithVerticalCenter:)]) {
        [_view styleWithVerticalCenter:verticalCenter];
    }
}

@end

