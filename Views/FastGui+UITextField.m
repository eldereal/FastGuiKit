//
//  FastGui+UITextField.m
//  exibitour
//
//  Created by 易元 白 on 15/4/4.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui+UITextField.h"

#import <objc/runtime.h>
#import <REKit/REKit.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>

#import "FGTypes.h"
#import "FGInternal.h"
#import "FGStyle.h"
#import "UIView+changingResult.h"
#import "UITextField+dismissFirstResponderTouchOutside.h"

@interface UITextField(FastGui_UITextField)

@property (nonatomic, strong) NSDate * fg_nextUpdateTime;

@end

@implementation FastGui (UITextField)

+ (NSString *) textField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:nil isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:placeHolder isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:nil isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:placeHolder isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *)textFieldWithPlaceHolder:(NSString *)placeHolder focus:(FGTextFieldFocus)focus styleClass:(NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:placeHolder isPassword:NO focus: focus update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:nil isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil placeHolder:placeHolder isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:nil isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass placeHolder:placeHolder isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}


+ (NSString *) textFieldWithReuseId: (NSString *)reuseId styleClass: (NSString *)styleClass  placeHolder: (NSString *)placeHolder isPassword: (BOOL) isPassword focus:(FGTextFieldFocus)focus update: (FGTextFieldUpdate) updatePolicy
{
    return [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UITextField *text = (UITextField *) reuseView;
        if (text == nil) {
            text = [[UITextField alloc] init];
            
            if (focus & FGTextFieldFocusAtStart) {
                [text respondsToSelector:@selector(didMoveToSuperview) withKey:nil usingBlock:^(UITextField* text){
                    [text becomeFirstResponder];
                    void (*super)(id, SEL) = (void (*)(id, SEL)) [text supermethodOfCurrentBlock];
                    if (super) {
                        super(text, @selector(didMoveToSuperview));
                    }
                }];
            }
        }
        [text bk_removeEventHandlersForControlEvents:UIControlEventEditingChanged];
        if (updatePolicy == FGTextFieldUpdateOnChange) {
            [text bk_addEventHandler:^(id sender) {
                [FastGui reloadGui];
            } forControlEvents:UIControlEventEditingChanged];
        }
        else if(updatePolicy == FGTextFieldUpdateShortAfterChange)
        {
            [text bk_addEventHandler:^(UITextField * text) {
                text.fg_nextUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0.5];
                
                FGVoidBlock update;
                __block __weak FGVoidBlock weakUpdate;
                weakUpdate = update = ^{
                    if (text.fg_nextUpdateTime == nil) {
                        return;
                    }
                    NSTimeInterval timeToUpdate = [text.fg_nextUpdateTime timeIntervalSinceNow];
                    if (timeToUpdate < 0) {
                        text.fg_nextUpdateTime = nil;
                        [FastGui reloadGui];
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((timeToUpdate+0.01) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakUpdate);
                    }
                };
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.51 * NSEC_PER_SEC)), dispatch_get_main_queue(), update);
            } forControlEvents:UIControlEventEditingChanged];
        }
        [text setDismissFirstResponderTouchOutsideEnabled:focus & FGTextFieldFocusDismissTouchOutside];
        if (focus & FGTextFieldFocusSet) {
            [text becomeFirstResponder];
        }else if (focus & FGTextFieldFocusDismiss) {
            [text resignFirstResponder];
        }
        text.placeholder = placeHolder;
        text.secureTextEntry = isPassword;
        return text;
    } resultBlock:^id(UIView *view) {
        UITextField *text = (UITextField *) view;
        return text.text;
    }];
}


@end

@implementation UITextField(FastGui_UITextField)

static void * NextUpdateTimePropertyKey = &NextUpdateTimePropertyKey;

- (NSDate *) fg_nextUpdateTime
{
    return objc_getAssociatedObject(self, NextUpdateTimePropertyKey);
}

- (void)setFg_nextUpdateTime:(NSDate *)fg_nextUpdateTime
{
    objc_setAssociatedObject(self, NextUpdateTimePropertyKey, fg_nextUpdateTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
