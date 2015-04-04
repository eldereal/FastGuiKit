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
#import "UIView+changingResult.h"

@interface UITextField(FastGui_UITextField)

@property (nonatomic, strong) NSDate * fg_nextUpdateTime;

@end

@implementation FastGui (UITextField)

+ (NSString *) textField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:nil isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:placeHolder isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:nil isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:placeHolder isPassword:NO focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *)textFieldWithPlaceHolder:(NSString *)placeHolder focus:(FGTextFieldFocus)focus styleClass:(NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:placeHolder isPassword:NO focus: focus update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) textFieldWithText: (NSString *) text placeHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:text placeHolder:placeHolder isPassword:NO focus: focus update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordField
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:nil isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:nil text:nil placeHolder:placeHolder isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:nil isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass
{
    return [self textFieldWithReuseId:[FGInternal callerPositionAsReuseId] styleClass:styleClass text:nil placeHolder:placeHolder isPassword:YES focus: FGTextFieldFocusDismissTouchOutside update:FGTextFieldUpdateShortAfterChange];
}


+ (NSString *) textFieldWithReuseId: (NSString *)reuseId styleClass: (NSString *)styleClass text:(NSString *)text placeHolder: (NSString *)placeHolder isPassword: (BOOL) isPassword focus:(FGTextFieldFocus)focus update: (FGTextFieldUpdate) updatePolicy
{
    return [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UITextField *textField = (UITextField *) reuseView;
        if (textField == nil) {
            textField = [[UITextField alloc] init];
            
            if (focus & FGTextFieldFocusAtStart) {
                [textField respondsToSelector:@selector(didMoveToSuperview) withKey:nil usingBlock:^(UITextField* text){
                    [text becomeFirstResponder];
                    void (*super)(id, SEL) = (void (*)(id, SEL)) [text supermethodOfCurrentBlock];
                    if (super) {
                        super(text, @selector(didMoveToSuperview));
                    }
                }];
            }
        }
        if (!textField.changingResult && text != nil) {
            textField.text = text;
        }
        
        [textField bk_removeEventHandlersForControlEvents:UIControlEventEditingChanged];
        [textField bk_removeEventHandlersForControlEvents:UIControlEventEditingDidEndOnExit];
        
        if (updatePolicy & FGTextFieldUpdateOnChange) {
            [textField bk_addEventHandler:^(id sender) {
                [FastGui reloadGuiWithBeforeBlock:^{
                    textField.changingResult = textField.text;
                } withAfterBlock:^{
                    textField.changingResult = nil;
                }];
            } forControlEvents:UIControlEventEditingChanged];
        }
        else if(updatePolicy & FGTextFieldUpdateShortAfterChange)
        {
            [textField bk_addEventHandler:^(UITextField * textField) {
                textField.fg_nextUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0.5];
                
                FGVoidBlock update;
                __block __weak FGVoidBlock weakUpdate;
                weakUpdate = update = ^{
                    if (textField.fg_nextUpdateTime == nil) {
                        return;
                    }
                    NSTimeInterval timeToUpdate = [textField.fg_nextUpdateTime timeIntervalSinceNow];
                    if (timeToUpdate < 0) {
                        textField.fg_nextUpdateTime = nil;
                        [textField reloadGuiChangingResult:textField.text];
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((timeToUpdate+0.01) * NSEC_PER_SEC)), dispatch_get_main_queue(), weakUpdate);
                    }
                };
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.51 * NSEC_PER_SEC)), dispatch_get_main_queue(), update);
            } forControlEvents:UIControlEventEditingChanged];
        }
        if (updatePolicy & FGTextFieldUpdateOnReturn) {
            [textField bk_addEventHandler:^(UITextField * textField) {
                [textField reloadGuiChangingResult:textField.text];
            } forControlEvents: UIControlEventEditingDidEndOnExit];
        }
        
        [textField setDismissFirstResponderTouchOutsideEnabled:focus & FGTextFieldFocusDismissTouchOutside];
        
        if (focus & FGTextFieldFocusDismissOnReturn)
        {
            [textField bk_addEventHandler:^(UITextField * textField) {
                [textField resignFirstResponder];
            } forControlEvents: UIControlEventEditingDidEndOnExit];
        }
        if (focus & FGTextFieldFocusSet) {
            [textField becomeFirstResponder];
        }else if (focus & FGTextFieldFocusDismiss) {
            [textField resignFirstResponder];
        }
        
        textField.placeholder = placeHolder;
        textField.secureTextEntry = isPassword;
        return textField;
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

@implementation FGStyle(UITextField)

+ (void) textFieldReturnKey: (UIReturnKeyType) returnKey
{
    [FGStyle customStyleWithBlock:^(UIView *view) {
        if ([view isKindOfClass:[UITextField class]]) {
            ((UITextField *) view).returnKeyType = returnKey;
        }
    }];
}

@end
