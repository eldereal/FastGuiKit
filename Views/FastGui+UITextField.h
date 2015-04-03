//
//  FastGui+UITextField.h
//  exibitour
//
//  Created by 易元 白 on 15/4/4.
//  Copyright (c) 2015年 cn.myzgstudio. All rights reserved.
//

#import "FastGui.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, FGTextFieldFocus)
{
    FGTextFieldFocusNone = 0,
    FGTextFieldFocusDismissTouchOutside = 1,
    FGTextFieldFocusAtStart = 2,
    FGTextFieldFocusSet = 4,
    FGTextFieldFocusDismiss = 8
};

typedef NS_ENUM(NSUInteger, FGTextFieldUpdate)
{
    FGTextFieldUpdateNone = 0,
    FGTextFieldUpdateOnChange,
    FGTextFieldUpdateShortAfterChange
};

@interface FastGui (UITextField)

+ (NSString *) textField;

+ (NSString *) textFieldWithText: (NSString *) text placeHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus styleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder;

+ (NSString *) textFieldWithStyleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass;

+ (NSString *) textFieldWithPlaceHolder: (NSString *)placeHolder focus: (FGTextFieldFocus) focus styleClass: (NSString *)styleClass;

+ (NSString *) passwordField;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder;

+ (NSString *) passwordFieldWithStyleClass: (NSString *)styleClass;

+ (NSString *) passwordFieldWithPlaceHolder: (NSString *)placeHolder styleClass: (NSString *)styleClass;

@end
