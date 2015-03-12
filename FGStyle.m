//
//  FGStyle.m
//  train-helper
//
//  Created by 易元 白 on 15/3/10.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FGStyle.h"

@implementation FGStyle

static UIView *_view;

static BOOL _setFrame;

static CGFloat _left;
static CGFloat _right;
static CGFloat _top;
static CGFloat _bottom;
static CGFloat _height;
static CGFloat _width;


+ (void) updateStyleOfView: (UIView *) view withBlock: (FGStyleBlock) block
{
    _view = view;
    _setFrame = false;
    _left = NAN;
    _right = NAN;
    _top = NAN;
    _bottom = NAN;
    _height = NAN;
    _width = NAN;

    if ([_view respondsToSelector: @selector(beginUpdateStyle)]) {
        [_view performSelector: @selector(beginUpdateStyle)];
    }
    @try {
        if(block != nil){
            block(_view);
        }
        if (_setFrame) {
            CGRect frame;
            BOOL preferSizeCalculated = NO;
            CGSize preferSize;
            if (!isnan(_left)) {
                frame.origin.x = _left;
                if (!isnan(_right)) {
                    frame.size.width = _view.superview.frame.size.width - _left - _right;
                }else if(!isnan(_width)){
                    frame.size.width = _width;
                }else{
                    if (!preferSizeCalculated){
                        preferSize = [_view sizeThatFits: _view.frame.size];
                        preferSizeCalculated = YES;
                    }
                    frame.size.width = preferSize.width;
                }
            }else if(!isnan(_right)){
                if(!isnan(_width)){
                    frame.origin.x = _view.superview.frame.size.width - _right - _width;
                    frame.size.width = _width;
                }else{
                    if (!preferSizeCalculated){
                        preferSize = [_view sizeThatFits: _view.frame.size];
                        preferSizeCalculated = YES;
                    }
                    frame.size.width = preferSize.width;
                    frame.origin.x = _view.superview.frame.size.width - _right - preferSize.width;
                }
            }else if(!isnan(_width)){
                frame.size.width = _width;
                frame.origin.x = (_view.superview.frame.size.width - _width) / 2;
            }else{
                if (!preferSizeCalculated){
                    preferSize = [_view sizeThatFits: _view.frame.size];
                    preferSizeCalculated = YES;
                }
                frame.size.width = preferSize.width;
                frame.origin.x = (_view.superview.frame.size.width - preferSize.width) / 2;
            }
            if (!isnan(_top)) {
                frame.origin.y = _top;
                if (!isnan(_bottom)) {
                    frame.size.height = _view.superview.frame.size.height - _top - _bottom;
                }else if(!isnan(_height)){
                    frame.size.height = _height;
                }else{
                    if (!preferSizeCalculated){
                        preferSize = [_view sizeThatFits: _view.frame.size];
                        preferSizeCalculated = YES;
                    }
                    frame.size.height = preferSize.height;
                }
            }else if(!isnan(_bottom )){
                if(!isnan(_height )){
                    frame.origin.y = _view.superview.frame.size.height - _bottom - _height;
                    frame.size.height = _height;
                }else{
                    if (!preferSizeCalculated){
                        preferSize = [_view sizeThatFits: _view.frame.size];
                        preferSizeCalculated = YES;
                    }
                    frame.size.height = preferSize.height;
                    frame.origin.y = _view.superview.frame.size.height - _bottom - preferSize.height;
                }
            }else if(!isnan(_height )){
                frame.size.height = _height;
                frame.origin.y = (_view.superview.frame.size.height - _height) / 2;
            }else{
                if (!preferSizeCalculated){
                    preferSize = [_view sizeThatFits: _view.frame.size];
                    preferSizeCalculated = YES;
                }
                frame.size.height = preferSize.height;
                frame.origin.y = (_view.superview.frame.size.height - preferSize.height) / 2;
            }
            
            _view.frame = frame;
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
    _setFrame = true;
    _top = top;
}

+ (void)right:(CGFloat)right
{
    _setFrame = true;
    _right = right;
}

+ (void) bottom:(CGFloat)bottom
{
    _setFrame = true;
    _bottom = bottom;
}

+ (void) left:(CGFloat)left
{
    _setFrame = true;
    _left = left;
}

+ (void)height:(CGFloat)height
{
    _setFrame = true;
    _height = height;
}

+ (void)width:(CGFloat)width
{
    _setFrame = true;
    _width = width;
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

+ (void)customStyle:(NSString *)key value:(id)value
{
    if ([_view respondsToSelector: @selector(styleWithCustomKey:value:)]) {
        [_view performSelector:@selector(styleWithCustomKey:value:) withObject:key withObject:value];
    }
}

@end

@interface UILabel(FGStyle)<FGStylable>

@end

@implementation UILabel(FGStyle)

- (void)styleWithColor:(UIColor *)color
{
    self.textColor = color;
}

@end
