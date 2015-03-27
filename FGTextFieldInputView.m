//
//  FastGui+FGTextFieldInputView.m
//  train-helper
//
//  Created by 易元 白 on 15/3/26.
//  Copyright (c) 2015年 eldereal. All rights reserved.
//
#import <objc/runtime.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <REKit/REKit.h>

#import "FGTextFieldInputView.h"
#import "FGInternal.h"
#import "UIView+changingResult.h"
#import "FGViewGroup.h"
#import "FGNullViewContext.h"
#import "FGTextFieldDismissFirstResponderTouchOutside.h"

@interface FGTextFieldInputViewContext : FGNullViewContext

@property (nonatomic, strong) UIView *reuseView;

@property (nonatomic, weak) UITextField *textField;

@end

@interface UITextField (FGTextFieldInputView)

@property(nonatomic, strong) FGTextFieldInputViewContext *inputViewGuiContext;

@end

static void * InputViewOfTextFieldDismissMethodKey = &InputViewOfTextFieldDismissMethodKey;

@implementation FastGui (FGTextFieldInputView)

+ (NSString *)beginInputViewOfTextFieldWithText:(NSString *)text
{
    if (text==nil) {
        text = @"";
    }
    return [self beginInputViewOfTextFieldWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass:nil];
}

+ (NSString *)beginInputViewOfTextFieldWithText:(NSString *)text styleClass:(NSString *)styleClass
{
    if (text==nil) {
        text = @"";
    }
    return [self beginInputViewOfTextFieldWithReuseId:[FGInternal callerPositionAsReuseId] text:text styleClass: styleClass];
}

+ (NSString *)beginInputViewOfTextField
{
    return [self beginInputViewOfTextFieldWithReuseId:[FGInternal callerPositionAsReuseId] text:nil styleClass: nil];
}

+ (NSString *)beginInputViewOfTextFieldWithStyleClass:(NSString *)styleClass
{
    return [self beginInputViewOfTextFieldWithReuseId:[FGInternal callerPositionAsReuseId] text:nil styleClass: styleClass];
}

+ (NSString *)beginInputViewOfTextFieldWithReuseId: (NSString *) reuseId text:(NSString *)text styleClass:(NSString *)styleClass
{
    UITextField *textField = [self customViewWithClass:styleClass reuseId:reuseId initBlock:^UIView *(UIView *reuseView) {
        UITextField *textField = (UITextField *) reuseView;
        if (textField == nil) {
            textField = [[FGTextFieldDismissFirstResponderTouchOutside alloc] init];
            [textField respondsToSelector:@selector(caretRectForPosition:) withKey:nil usingBlock:^CGRect(id self){
                return CGRectZero;
            }];
            textField.inputViewGuiContext = [[FGTextFieldInputViewContext alloc] init];
            textField.inputViewGuiContext.textField = textField;
            [textField bk_addEventHandler:^(id sender) {
                UITextField *textField = (UITextField *)sender;
                [textField reloadGuiChangingResult: textField.text];
            } forControlEvents:UIControlEventEditingChanged];
        }
        return textField;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    NSString * result;
    if (textField.changingResult != nil) {
        result = textField.changingResult;
    }else{
        if (text != nil) {
            textField.text = text;
        }
        result = textField.text;
    }
    [self pushContext: textField.inputViewGuiContext];
    [self beginGroupWithNextView];
    UIView *view = [self customViewWithClass:nil reuseId:nil initBlock:^UIView *(UIView *reuseView) {
        if (reuseView == nil) {
            reuseView = [[UIView alloc] init];
            reuseView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        return reuseView;
    } resultBlock:^id(UIView *view) {
        return view;
    }];
    textField.inputView = view;
    return result;
}

+ (void)inputViewOfTextFieldDismiss
{
    [self customData:InputViewOfTextFieldDismissMethodKey data:nil];
}

+ (void) endInputViewOfTextField
{
    [self endGroup];
    [self popContext];
}

@end

@implementation FGTextFieldInputViewContext

- (id)customViewWithReuseId:(NSString *)reuseId initBlock:(FGInitCustomViewBlock)initBlock resultBlock:(FGGetCustomViewResultBlock)resultBlock applyStyleBlock:(FGStyleBlock)applyStyleBlock
{
    self.reuseView = initBlock(self.reuseView);
    applyStyleBlock(self.reuseView);
    if (resultBlock == nil) {
        return nil;
    }else{
        return resultBlock(self.reuseView);
    }
}

- (id)customData:(void *)key data:(NSDictionary *)data
{
    if (key == InputViewOfTextFieldDismissMethodKey) {
        [self.textField resignFirstResponder];
        return nil;
    }
    return [self.parentContext customData:key data:data];
}

@end

@implementation UITextField(FGTextFieldInputView)

static void * InputViewGuiContextPropertyKey = &InputViewGuiContextPropertyKey;

- (FGTextFieldInputViewContext *)inputViewGuiContext
{
    return objc_getAssociatedObject(self, InputViewGuiContextPropertyKey);
}

- (void)setInputViewGuiContext:(FGTextFieldInputViewContext *)inputViewGuiContext
{
    objc_setAssociatedObject(self, InputViewGuiContextPropertyKey, inputViewGuiContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
