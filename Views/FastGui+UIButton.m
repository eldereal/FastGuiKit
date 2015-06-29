//
//  FastGui+UIButton.m
//  train-helper
//
//  Created by 易元 白 on 15/3/27.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//

#import "FastGui+UIButton.h"
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <BlocksKit/NSObject+A2DynamicDelegate.h>
#import <objc/runtime.h>

#import "FGTypes.h"
#import "FGInternal.h"
#import "FGStyle.h"
#import <REKit/REKit.h>
#import "UIView+changingResult.h"

@implementation FastGui (UIButton)

+ (BOOL)buttonWithTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:NO] title: title selectedTitle:title imageName:nil styleClass: styleClass];
}

+ (BOOL) toggleButtonWithTitle:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:title imageName:nil styleClass: nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:title imageName:nil styleClass: styleClass];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:selectedTitle imageName:nil styleClass:nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:selectedTitle imageName:nil styleClass:styleClass];
}

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:title imageName:nil styleClass: nil];
}

+ (BOOL)toggleButtonWithSelected: (BOOL) selected title:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:title imageName:nil styleClass: styleClass];
}

+ (BOOL)toggleButtonWithSelected: (BOOL) selected title:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:selectedTitle imageName:nil styleClass:nil];
}

+ (BOOL)toggleButtonWithSelected: (BOOL) selected title:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:selectedTitle imageName:nil styleClass:styleClass];
}


+ (BOOL)toggleButtonWithReuseId:(NSString *)reuseId selected: (NSNumber *)selected title:(NSString *)title selectedTitle:(NSString *)selectedTitle imageName:(NSString *)imageName styleClass:(NSString *)styleClass
{
    NSNumber *ret = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UIButton *btn = (UIButton *) reuseView;
        if (btn == nil){
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn bk_addEventHandler:^(UIButton *btn) {
                btn.selected = !btn.selected;
                [btn reloadGuiChangingResult:[NSNumber numberWithBool:btn.selected]];
            } forControlEvents:UIControlEventTouchUpInside];
        }
        if (selected != nil) {
            if (btn.changingResult == nil) {
                btn.selected = [selected boolValue];
            }
        }
        [UIView setAnimationsEnabled:NO];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
        if (imageName == nil) {
            [btn setImage:nil forState:UIControlStateNormal];
        }else{
            [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
        [UIView setAnimationsEnabled:YES];
        return btn;
    } resultBlock:^id(UIView *view) {
        UIButton *btn = (UIButton *) view;
        if (btn.changingResult) {
            return btn.changingResult;
        }else{
            return [NSNumber numberWithBool: btn.selected];
        }
    }];
    return ret.boolValue;
}

+ (BOOL)imageButtonWithName:(NSString *)imageName styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:NO] title:nil selectedTitle:nil imageName:imageName styleClass:styleClass];
}

+ (BOOL)imageButtonWithName:(NSString *)imageName withTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:NO] title:title selectedTitle:nil imageName:imageName styleClass:styleClass];
}
@end

@implementation FGStyle (UIButton)

+ (void) imageButtonImageTextSpacing: (CGFloat) spacing
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        }
    }];
}

@end
