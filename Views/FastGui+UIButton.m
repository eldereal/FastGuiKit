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

+ (void)buttonWithTitle:(NSString *)title styleClass:(NSString *)styleClass onClick:(FGVoidBlock)onClick
{
    [self customViewWithClass:styleClass reuseId:[FGInternal callerPositionAsReuseId] initBlock:^UIView *(UIView *reuseView) {
        UIButton *btn = (UIButton *) reuseView;
        if (btn == nil) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:btn action:@selector(notify) forControlEvents:UIControlEventTouchUpInside];
        }
        [btn respondsToSelector:@selector(notify) withKey:nil usingBlock:^(id btn){
            onClick();
        }];
        [UIView setAnimationsEnabled:NO];
        [btn setTitle:title forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        return btn;
    } resultBlock:nil];
}

+ (BOOL)buttonWithTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:NO] title: title selectedTitle:title styleClass: styleClass];
}

+ (BOOL) toggleButtonWithTitle:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:title styleClass: nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:title styleClass: styleClass];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:selectedTitle styleClass:nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:nil title: title selectedTitle:selectedTitle styleClass:styleClass];
}

+ (BOOL) toggleButtonWithSelected: (BOOL) selected title:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:title styleClass: nil];
}

+ (BOOL)toggleButtonWithSelected: (BOOL) selected title:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:title styleClass: styleClass];
}

+ (BOOL)toggleButtonWithSelected: (BOOL) selected title:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:selectedTitle styleClass:nil];
}

+ (BOOL)toggleButtonWithSelected: (BOOL) selected title:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] selected:[NSNumber numberWithBool:selected] title: title selectedTitle:selectedTitle styleClass:styleClass];
}


+ (BOOL)toggleButtonWithReuseId:(NSString *)reuseId selected: (NSNumber *)selected title:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    NSNumber *ret = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UIButton *btn = (UIButton *) reuseView;
        if (btn == nil){
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn bk_addEventHandler:^(id sender) {
                UIButton *btn = sender;
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

@end
