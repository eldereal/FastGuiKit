//
//  FGBasicViews.m
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import <objc/runtime.h>
#import "FGBasicViews.h"
#import "FGTypes.h"
#import "FGInternal.h"

static void * OnClickHolderPropertyKey = &OnClickHolderPropertyKey;

@interface UIButton (FGBasicViews)

@property (nonatomic, strong) FGVoidBlockHolder *onClickHolder;

@end

@implementation UIButton (FGBasicViews)

- (FGVoidBlockHolder *)onClickHolder
{
    return objc_getAssociatedObject(self, OnClickHolderPropertyKey);
}

- (void) setOnClickHolder:(FGVoidBlockHolder *)onClickHolder
{
    objc_setAssociatedObject(self, OnClickHolderPropertyKey, onClickHolder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FastGui(FGBasicViews)

+ (void) block
{
    [self blockWithColor:[UIColor colorWithWhite:0 alpha:0] styleClass:nil];
}

+ (void)blockWithStyleClass:(NSString *)styleClass
{
    [self blockWithColor:[UIColor colorWithWhite:0 alpha:0] styleClass:styleClass];
}

+ (void) blockWithColor:(UIColor *)color styleClass: (NSString *)styleClass
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGNotifyCustomViewResultBlock notifyResult, FGStyleBlock applyStyle) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
        }
        applyStyle(reuseView);
        reuseView.backgroundColor = color;
        return reuseView;
    } resultBlock: nil];
}

+ (void) labelWithText:(NSString *)text
{
    NSString *reuseId = [FGInternal callerPositionAsReuseId];
    [self customViewWithClass:nil reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGNotifyCustomViewResultBlock notifyResult, FGStyleBlock applyStyle) {
        UILabel *label = (UILabel *) reuseView;
        if(label == nil){
            label = [[UILabel alloc] init];
        }
        applyStyle(label);
        label.text = text;
        return label;
    } resultBlock: nil];
}

+ (BOOL) toggleButtonWithTitle:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:title];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:selectedTitle];
}

+ (BOOL)toggleButtonWithReuseId:(NSString *)reuseId title:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    NSNumber *ret = [self customViewWithClass:nil reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGNotifyCustomViewResultBlock notifyResult, FGStyleBlock applyStyle) {
        UIButton *btn = (UIButton *) reuseView;
        if (btn == nil){
            btn = [UIButton buttonWithType:UIButtonTypeSystem];
            __weak UIButton *weakBtn = btn;
            FGVoidBlockHolder *onClickHolder = [FGVoidBlockHolder holderWithBlock:^{
                if (weakBtn != nil){
                    weakBtn.selected = !weakBtn.selected;
                    [weakBtn.notifyHolder notify];
                }
            }];
            btn.onClickHolder = onClickHolder;
            [btn addTarget:onClickHolder action:@selector(notify) forControlEvents:UIControlEventTouchUpInside];
        }
        applyStyle(btn);
        btn.notifyHolder = [FGNotifyCustomViewResultHolder holderWithBlock:notifyResult];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
        return btn;
    } resultBlock:^id(UIView *view) {
        UIButton *btn = (UIButton *) view;
        return [NSNumber numberWithBool: btn.selected];
    }];
    return ret.boolValue;
}

@end
