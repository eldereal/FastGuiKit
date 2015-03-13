//
//  FGBasicViews.m
//  exibitour
//
//  Created by 易元 白 on 15/3/9.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/NSObject+A2DynamicDelegate.h>
#import <objc/runtime.h>
#import "FGBasicViews.h"
#import "FGTypes.h"
#import "FGInternal.h"
#import "FGStyle.h"

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

@interface FGColoredBlock : UIView<FGStylable>

@end

@implementation FGColoredBlock

- (void)styleWithBackgroundColor:(UIColor *)backgroundColor
{
    //this block ignores backgroundColor style;
}

@end

@implementation FastGui(FGBasicViews)

+ (void) block
{
    [self blockWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void)blockWithStyleClass:(NSString *)styleClass
{
    [self blockWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void)blockWithReuseId: (NSString *) reuseId styleClass:(NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGVoidBlock notifyResult) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
        }
        return reuseView;
    } resultBlock: nil];
}

+ (void)blockWithColor:(UIColor *)color
{
    [self blockWithColor:color withReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil];
}

+ (void)blockWithColor:(UIColor *)color styleClass:(NSString *)styleClass
{
    [self blockWithColor:color withReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass];
}

+ (void) blockWithColor:(UIColor *)color withReuseId: (NSString *)reuseId styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGVoidBlock notifyResult) {
        FGColoredBlock *view = (FGColoredBlock *)reuseView;
        if (view == nil) {
            view = [[FGColoredBlock alloc] init];
            
        }
        view.backgroundColor = color;
        return view;
    } resultBlock: nil];
}

+ (void)labelWithText:(NSString *)text
{
    [self labelWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass:nil];
}

+ (void)labelWithText:(NSString *)text styleClass:(NSString *)styleClass
{
    [self labelWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass: styleClass];
}

+ (void) labelWithReuseId:(NSString *)reuseId text: (NSString *)text styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGVoidBlock notifyResult) {
        UILabel *label = (UILabel *) reuseView;
        if(label == nil){
            label = [[UILabel alloc] init];
        }
        label.text = text;
        return label;
    } resultBlock: nil];
}

+ (void)imageWithName:(NSString *)name
{
    [self imageWithReuseId:[FGInternal callerPositionAsReuseId] imageNamed:name styleClass:nil];
}

+ (void)imageWithName:(NSString *)name styleClass:(NSString *)styleClass
{
    [self imageWithReuseId:[FGInternal callerPositionAsReuseId] imageNamed:name styleClass:styleClass];
}

+ (void)imageWithReuseId:(NSString *)reuseId imageNamed: (NSString *)name styleClass: (NSString *)styleClass
{
    [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGVoidBlock notifyResult) {
        UIImageView *img = (UIImageView *) reuseView;
        if(img == nil){
            img = [[UIImageView alloc] init];
        }
        img.image = [UIImage imageNamed: name];
        return img;
    } resultBlock: nil];
}

+ (BOOL) toggleButtonWithTitle:(NSString *)title
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:title styleClass: nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:title styleClass: styleClass];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:selectedTitle styleClass:nil];
}

+ (BOOL)toggleButtonWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    return [self toggleButtonWithReuseId:[FGInternal callerPositionAsReuseId] title: title selectedTitle:selectedTitle styleClass:styleClass];
}

+ (BOOL)toggleButtonWithReuseId:(NSString *)reuseId title:(NSString *)title selectedTitle:(NSString *)selectedTitle styleClass:(NSString *)styleClass
{
    NSNumber *ret = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView, FGVoidBlock notifyResult) {
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
